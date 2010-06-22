module Net
  class HTTP
    alias request_without_ephemeral_response request
    alias connect_without_ephemeral_response connect

    attr_reader :uri

    def connect
    end
    private :connect

    def do_start_without_ephemeral_response
      D "EphemeralResponse: establishing connection to #{uri}"
      connect_without_ephemeral_response
      @started = true
    end
    private :do_start_without_ephemeral_response

    def generate_uri(request)
      scheme = use_ssl? ? "https" : "http"
      @uri = URI.parse("#{scheme}://#{conn_address}:#{conn_port}#{request.path}")
    end

    def request(request, body = nil, &block)
      generate_uri(request)
      EphemeralResponse::Fixture.respond_to(uri, request) do
        do_start_without_ephemeral_response
        request_without_ephemeral_response(request, body, &block)
      end
    end
  end
end
