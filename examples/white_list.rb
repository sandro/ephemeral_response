$LOAD_PATH.unshift("lib")
require 'rubygems'
require './lib/ephemeral_response'

# Don't create fixtures for the localhost domain
EphemeralResponse::Configuration.white_list = 'localhost'

EphemeralResponse::Configuration.expiration = 5
EphemeralResponse.activate

# Start an HTTP server on port 19876 using netcat
process = IO.popen %(echo "HTTP/1.1 200 OK\n\n" | nc -l 19876)
at_exit { Process.kill :KILL, process.pid }
sleep 1

# Make a request to the server started above
# No new fixtures are created in spec/fixtures/ephemeral_response/
uri = URI.parse('http://localhost:19876/')
Net::HTTP.get(uri)

# Fixtures are still created for Google
uri = URI.parse('http://www.google.com/')
Net::HTTP.get(uri)

puts "The directory should not contain a fixture for localhost"
puts
dir = File.expand_path(EphemeralResponse::Configuration.fixture_directory)
puts %x(set -x; ls -l #{dir})
