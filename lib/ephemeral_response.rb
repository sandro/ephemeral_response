require 'net/http'
require 'fileutils'
require 'time'
require 'digest/sha1'
require 'yaml'
require 'ephemeral_response/net_http'
require 'ephemeral_response/configuration'
require 'ephemeral_response/fixture'

module EphemeralResponse
  VERSION = "0.0.0".freeze

  def self.activate
    Fixture.load_all
  end
end
