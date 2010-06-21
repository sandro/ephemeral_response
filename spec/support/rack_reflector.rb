require 'unicorn'

module EphemeralResponse::RackReflector
  class Response
    attr_reader :ordered_headers, :rack_input
    def initialize(env={})
      @ordered_headers = []
      set_ordered_headers(env)
      set_rack_input(env)
    end

    def set_ordered_headers(env)
      env.each do |key, value|
        @ordered_headers << [key, value] if key == key.upcase
      end
    end

    def headers
      Hash[ordered_headers]
    end

    def set_rack_input(env)
      @rack_input = env['rack.input'].read
    end
  end

  extend self

  def app
    lambda do |env|
      [ 200, {"Content-Type" => "application/x-yaml"}, [ Response.new(env).to_yaml ] ]
    end
  end

  def new_server
    http_server = Unicorn::HttpServer.new(app, :listeners => ["0.0.0.0:#{port}"])
    http_server.logger.level = Logger::ERROR
    http_server
  end

  def port
    9876 || ENV['UNICORN_PORT']
  end

  def server
    @server ||= new_server
  end

  def start
    server.start
  end

  def stop
    server.stop(false)
  end

  def while_running
    start
    yield
  ensure
    stop
  end
end
