$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'net/https'
require 'ephemeral_response'
require 'fakefs/safe'
require 'fakefs/spec_helpers'
require 'spec/autorun'

Dir.glob("spec/support/*.rb") {|f| require File.expand_path(f, '.')}

Spec::Runner.configure do |config|
  config.include ClearFixtures
  config.before(:suite) do
    ClearFixtures.clear_fixtures
  end
  config.before(:each) do
    EphemeralResponse::Configuration.reset
    EphemeralResponse.activate
  end
  config.after(:suite) do
    EphemeralResponse.deactivate
    ClearFixtures.clear_fixtures
  end
end
