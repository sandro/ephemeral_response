$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'net/https'
require 'ephemeral_response'
require 'fakefs/safe'
require 'fakefs/spec_helpers'
require 'rspec/autorun'
require 'debugger'

Dir.glob("spec/support/*.rb") {|f| require File.expand_path(f, '.')}

class Net::HTTPResponse
  def equality_test
    [http_version, code, message, body]
  end

  def ==(other)
    equality_test == other.equality_test
  end
end

RSpec.configure do |config|
  config.color = true
  config.include ClearFixtures

  config.before(:suite) do
    ClearFixtures.clear_fixtures
  end

  config.after(:suite) do
    EphemeralResponse.deactivate
    ClearFixtures.clear_fixtures
  end

  config.before(:each) do
    EphemeralResponse.activate
  end

  config.after(:each) do
    EphemeralResponse::Configuration.reset
  end
end
