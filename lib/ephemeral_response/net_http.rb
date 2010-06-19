module Net
  class HTTP
    alias request_without_ephemeral_response request
    alias connect_without_ephemeral_response connect

    attr_accessor :uri

    def connect
    end
    private :connect

    def generate_uri(request)
      scheme = use_ssl? ? "https" : "http"
      self.uri = URI.parse("#{scheme}://#{conn_address}:#{conn_port}#{request.path}")
    end

    def request(request, body = nil, &block)
      generate_uri(request)
      EphemeralResponse::Fixture.respond_to(uri, request) do
        D "EphemeralResponse: establishing connection to #{uri}"
        connect_without_ephemeral_response
        request_without_ephemeral_response(request, body, &block)
      end
    end
  end
end
