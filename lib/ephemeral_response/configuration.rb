module EphemeralResponse
  module Configuration
    extend self

    attr_writer :fixture_directory

    DEFAULTS = {
      :fixture_directory => "spec/fixtures/ephemeral_response",
      :expiration => lambda { one_day }
    }

    def fixture_directory
      @fixture_directory || DEFAULTS[:fixture_directory]
    end

    def expiration=(expiration)
      if expiration.is_a?(Proc)
        expiration = instance_eval &expiration
      end
      @expiration = validate_expiration(expiration)
    end

    def expiration
      @expiration || DEFAULTS[:expiration]
    end

    def reset
      self.expiration = DEFAULTS[:expiration]
      self.fixture_directory = DEFAULTS[:fixture_directory]
    end

    protected

    def one_day
      60 * 60 * 24
    end

    def validate_expiration(expiration)
      raise TypeError, "expiration must be expressed in seconds" unless expiration.is_a?(Fixnum)
      expiration
    end

  end
end
