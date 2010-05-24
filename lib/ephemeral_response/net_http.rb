module Net
  class HTTP
    alias request_without_ephemeral_response request
    alias connect_without_ephemeral_response connect

    def connect
    end
    private :connect

    def generate_uri(request)
      scheme = use_ssl? ? "https" : "http"
      URI.parse("#{scheme}://#{conn_address}:#{conn_port}#{request.path}")
    end

    def request(request, body = nil, &block)
      EphemeralResponse::Fixture.respond_to(generate_uri(request), request.method) do
        connect_without_ephemeral_response
        request_without_ephemeral_response(request, body, &block)
      end
    end
  end
end
