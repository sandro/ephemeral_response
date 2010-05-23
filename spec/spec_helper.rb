$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'net/https'
require 'ephemeral_response'
require 'fakefs/safe'
require 'fakefs/spec_helpers'
require 'spec/autorun'
Dir.glob("spec/support/*.rb") {|f| require f}

Spec::Runner.configure do |config|
  config.include FakeFS::SpecHelpers
  config.include ClearFixtures
end
