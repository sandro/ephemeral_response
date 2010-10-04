module EphemeralResponse
  module Configuration
    extend self

    attr_accessor :current_set
    attr_writer :fixture_directory, :skip_expiration

    def effective_directory
      if current_set.nil? or current_set.to_s == 'default'
        fixture_directory
      else
        File.join(fixture_directory, current_set.to_s)
      end
    end

    def fixture_directory
      @fixture_directory || "spec/fixtures/ephemeral_response"
    end

    def expiration=(expiration)
      if expiration.is_a?(Proc)
        expiration = instance_eval &expiration
      end
      @expiration = validate_expiration(expiration)
    end

    def expiration
      @expiration || one_day
    end

    def host_registry
      @host_registry ||= Hash.new(proc {})
    end

    def register(host, &block)
      host_registry[host] = block
    end

    def reset
      @current_set = nil
      @expiration = nil
      @fixture_directory = nil
      @white_list = nil
      @skip_expiration = nil
      @host_registry = nil
    end

    def skip_expiration
      @skip_expiration || false
    end

    def white_list
      @white_list ||= []
    end

    def white_list=(*hosts)
      @white_list = hosts.flatten
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
