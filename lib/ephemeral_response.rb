module EphemeralResponse
  require 'ephemeral_response/proxy'
  autoload :CacheService, 'ephemeral_response/cache_service'
  autoload :Commands, 'ephemeral_response/commands'
  autoload :Configuration, 'ephemeral_response/configuration'
  autoload :Fixture, 'ephemeral_response/fixture'
  autoload :Request, 'ephemeral_response/request'

  VERSION = "0.4.0".freeze

  Error = Class.new(StandardError)

  extend Commands
end
