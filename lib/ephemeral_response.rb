module EphemeralResponse
  autoload :Commands, 'ephemeral_response/commands'
  autoload :Configuration, 'ephemeral_response/configuration'
  autoload :Fixture, 'ephemeral_response/fixture'
  autoload :NullOutput, 'ephemeral_response/null_output'
  autoload :Request, 'ephemeral_response/request'

  VERSION = "0.4.0".freeze

  Error = Class.new(StandardError)

  extend Commands
end
