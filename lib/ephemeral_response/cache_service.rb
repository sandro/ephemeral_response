module EphemeralResponse
  class CacheService
    attr_accessor :request

    def cached?
      Fixture.find(uri, http_request)
    end

    def get_cached_response
      fixture = Fixture.find(uri, http_request)
      fixture.raw_response
    end

    def cache(raw_response)
      fixture = Fixture.new(uri, http_request)
      fixture.raw_response = raw_response
      fixture.register
    end

    def http_request
      request.http_request
    end

    def uri
      request.uri
    end

  end
end
