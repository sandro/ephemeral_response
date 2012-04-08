module EphemeralResponse
  module Commands
    def activate
      deactivate
      server.start unless server && server.running?
      ::Net.module_eval do
        if const_defined?(:HTTP) && !const_defined?(:OHTTP)
          const_set(:OHTTP, remove_const(:HTTP))
          const_set(:HTTP, Net::ProxyHTTP)
        end
      end
      Fixture.load_all
    end

    def server
      @server ||= new_server
    end

    def new_server
      s = ProxyServer.new
      s.cache_service = CacheService.new
      s
    end

    def configure
      yield Configuration if block_given?
      Configuration
    end

    def fixture_set
      Configuration.fixture_set
    end

    def fixture_set=(name)
      Configuration.fixture_set = name
      Fixture.load_all
    end

    def deactivate
      server.stop
      ::Net.module_eval do
        if const_defined?(:OHTTP)
          remove_const(:HTTP)
          const_set(:HTTP, remove_const(:OHTTP))
        end
      end
    end

    def fixtures
      Fixture.fixtures
    end

    # FIXME: Don't deactivate and reactivate, instead set a flag which ignores
    # fixtures entirely.
    def live
      deactivate
      yield
      activate
    end
  end
end
