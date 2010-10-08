module Net
  class HTTP
    alias request_without_ephemeral_response request
    alias connect_without_ephemeral_response connect

    attr_reader :uri

    def connect
    end
    private :connect

    def do_start_with_ephemeral_response
      connect_without_ephemeral_response
      @started = true
    end
    private :do_start_with_ephemeral_response

    def generate_uri(request)
      scheme = use_ssl? ? "https" : "http"
      @uri = URI.parse("#{scheme}://#{conn_address}:#{conn_port}#{request.path}")
    end

    def request(request, body = nil, &block)
      generate_uri(request)
      request.set_body_internal body
      EphemeralResponse::Fixture.respond_to(uri, request, block) do
        do_start_with_ephemeral_response
        request_without_ephemeral_response(request, nil, &block)
      end
    end
  end

  module PersistentReadAdapter
    def _buffer
      @_buffer ||= ""
    end

    def <<(str)
      _buffer << str
      super
    end

    def to_yaml(opts = {})
      _buffer.to_yaml opts
    end

    def to_s
      _buffer
    end
  end

  class HTTPResponse
    alias procdest_without_ephemeral_response procdest
    alias read_body_without_ephemeral_response read_body

    def procdest(dest, block)
      to = procdest_without_ephemeral_response(dest, block)
      to.extend PersistentReadAdapter
    end

    def read_body(dest = nil, &block)
      if @read
        yield @body if block_given?
        @body
      else
        read_body_without_ephemeral_response(dest, &block)
      end
    end
  end
end
