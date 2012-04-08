require 'socket'
require 'uri'
require 'net/http'
require 'openssl'
require 'thread'

module Net

  class ProxyHTTP < HTTP
    include HTTP::ProxyDelta
    @is_proxy_class = true
    @proxy_address = 'localhost'
    @proxy_port    = 44567

    def initialize(*args)
      super
      self.verify_mode = nil
    end

    def verify_mode=(*args)
      @verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    alias verify_mode verify_mode=
  end

end

module EphemeralResponse

  class ProxyReader
    attr_reader :socket

    def initialize(socket)
      @socket = socket
    end

    def read
      request = catch(:request_done) do
        buf = ProxyRequest.new
        buf.tunnel_host = socket.tunnel_host if socket.respond_to?(:tunnel_host)
        while line = socket.gets
          buf << line
          if buf.complete?
            if buf.content_length?
              buf << socket.read(buf.content_length)
            end
            throw :request_done, buf
          end
        end
      end
    end
  end

  class ProxyRequest
    attr_accessor :tunnel_host
    attr_reader :raw

    def initialize(raw = "")
      @raw = raw || ""
    end

    def <<(str)
      raw << str
    end

    def complete?
      raw =~ /\r?\n\r?\n$/
    end

    def host
      uri.host
    end

    def port
      uri.port
    end

    def http_method
      @http_method ||= first_line[0]
    end

    def uri
      @uri ||= parse_uri
    end

    def parse_uri
      h = first_line[1]
      if tunnel_host
        h = "https://#{tunnel_host}#{h}"
      elsif h !~ /^https?:\/\//
        h = "http://#{h}"
      end
      begin
        URI.parse(h)
      rescue URI::InvalidURIError
        URI.parse(URI.escape(h))
      end
    end

    def http_version
      first_line[2]
    end

    def http_method_class
      ::Net::HTTP.const_get(http_method.downcase.capitalize)
    end

    def http_request
      req = http_method_class.new(uri.request_uri)
      req.set_form_data(form_data) unless form_data.empty?
      headers.each {|k,v| req[k] = v}
      req
    end

    def ssl_tunnel?
      http_method.upcase == "CONNECT"
    end

    def ssl?
      uri.scheme == "https" || uri.port == URI::HTTPS::DEFAULT_PORT
    end

    def to_s
      raw
    end

    def first_line
      @first_line ||= lines[0].split(" ", 3)
    end

    def lines
      @lines ||= raw.split(/\r?\n/)
    end

    def headers
      @headers ||= parse_headers
    end

    def parse_headers
      h = {}
      lines[1..-1].each do |header|
        k,v = header.split(": ", 2)
        h[k] = v if k && v
      end
      h
    end

    def content_length
      headers['Content-Length'].to_i
    end

    def content_length?
      content_length > 0
    end

    def form_data
      @form_data ||= parse_form_data
    end

    def parse_form_data
      h = {}
      if content_length?
        data = raw.split(/\r?\n\r?\n/, 2).last
        data.split("&").each do |set|
          k,v = set.split('=', 2)
          h[k] = v
        end
      end
      h
    end
  end

  class ProxyForwarder
    attr_reader :proxy_req, :response, :cache_service

    def initialize(proxy_req, cache_service=nil)
      @proxy_req = proxy_req
      @raw = ""
      self.cache_service = cache_service
    end

    def cache_service=(cache_service)
      if cache_service
        @cache_service = cache_service
        cache_service.request = proxy_req
        cache_service
      end
    end

    def start
      if cached?
        yield get_cached_response
      else
        make_request
        cache_response
        yield @raw
      end
    end

    def cached?
      if cache_service
        cache_service.cached?
      end
    end

    def cache_response
      if cache_service
        cache_service.cache(@raw)
      end
    end

    def get_cached_response
      cache_service.get_cached_response
    end

    def http_class
      Net.const_defined?(:OHTTP) ? Net::OHTTP : Net::HTTP
    end

    def make_request
      if proxy_req.ssl_tunnel?
        @raw = "#{proxy_req.http_version} 200 Connection established\r\n\r\n"
      else
        http = http_class.new(proxy_req.host, proxy_req.port)
        http.use_ssl = proxy_req.ssl?
        http.start do |http|
          http.request(proxy_req.http_request) do |response|
            @response = response
            @raw << response_headers
            response.read_body do |data|
              @raw << data
            end
          end
        end
      end
    end

    def response_headers
      h = ["HTTP/#{response.http_version} #{response.code} #{response.message}"]
      response.each_capitalized do |k,v|
        unless ['Transfer-Encoding'].include?(k)
          h << "#{k}: #{v}"
        end
      end
      h.join("\r\n") << "\r\n\r\n"
    end
  end

  module SSLTunnel
    attr_accessor :tunnel_host
  end

  class ProxyServer
    Thread.abort_on_exception = true

    attr_reader :ios, :server, :server_thread, :mutex
    attr_accessor :port, :cache_service

    def initialize(port=nil)
      @ios = []
      @server_thread = []
      @mutex = Mutex.new
      self.port = port || 44567
    end

    def dir
      File.expand_path(File.dirname(__FILE__))
    end

    def certificate_path
      File.join(dir, "certificate.pem")
    end

    def key_path
      File.join(dir, "key.pem")
    end

    def ssl_sock(sock)
      context = OpenSSL::SSL::SSLContext.new
      context.cert = OpenSSL::X509::Certificate.new(File.open(certificate_path))
      context.key = OpenSSL::PKey::RSA.new(File.open(key_path))
      ssl = OpenSSL::SSL::SSLSocket.new(sock, context)
      ssl.sync_close = true
      ssl
    end

    def server
      @server ||= TCPServer.new(port)
    end

    def start
      ios << server
      @running = true
      @stopping = false
      @server_thread = Thread.new do
        while true
          selection = select(ios, [], [], 0.1)
          if selection
            selection.first.each do |socket_ready|
              if socket_ready.closed?
                $stderr.puts "#{self.class.name}: socket closed: #{socket_ready.inspect}"
              else
                handle(socket_ready)
              end
            end
          end
          break if @stopping
        end
      end
      self
    end

    def running?
      @running
    end

    def join
      server_thread.join
    end

    def stop
      ios.clear
      @stopping = true
      @running = false
    end

    def handle(socket_ready)
      s = socket_ready.accept
      reader = ProxyReader.new(s)
      request = reader.read

      if request
        forwarder = ProxyForwarder.new(request, cache_service)
        forwarder.start do |str|
          s.print(str) unless s.closed?
        end
        if request.ssl_tunnel?
          ssl = ssl_sock(s)
          ssl.extend SSLTunnel
          ssl.tunnel_host = request.host
          mutex.synchronize { ios << ssl }
        else
          s.close
          mutex.synchronize { ios.delete(s) }
        end
      else
        puts "No request #{request.inspect}"
        s.close
      end
    end
  end
end
