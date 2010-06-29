require 'net/http'
require 'fileutils'
require 'time'
require 'digest/sha1'
require 'yaml'
require 'ephemeral_response/configuration'
require 'ephemeral_response/fixture'

module EphemeralResponse
  VERSION = "0.3.0".freeze

  def self.activate
    deactivate
    load 'ephemeral_response/net_http.rb'
    Fixture.load_all
  end

  def self.deactivate
    Net::HTTP.class_eval do
      remove_method(:generate_uri) if method_defined?(:generate_uri)
      remove_method(:uri) if method_defined?(:uri)
      alias_method(:connect, :connect_without_ephemeral_response) if private_method_defined?(:connect_without_ephemeral_response)
      alias_method(:request, :request_without_ephemeral_response) if method_defined?(:request_without_ephemeral_response)
    end
  end

  def self.fixtures
    Fixture.fixtures
  end

  def self.configure
    yield Configuration if block_given?
    Configuration
  end
end
