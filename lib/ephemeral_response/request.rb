module EphemeralResponse
  class Request < SimpleDelegator
    attr_reader :uri

    undef method

    def initialize(uri, request)
      @uri = uri
      super request
    end
  end
end
