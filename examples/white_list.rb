$LOAD_PATH.unshift("lib")
require 'rubygems'
require 'lib/ephemeral_response'

# Don't create fixtures for the localhost domain
EphemeralResponse::Configuration.white_list = 'localhost'

EphemeralResponse::Configuration.expiration = 1
EphemeralResponse.activate

# Start an HTTP server on port 9876 using netcat
IO.popen %(echo "HTTP/1.1 200 OK\n\n" | nc -l 9876)
sleep 1

# Make a request to the server started above
# No new fixtures are created in spec/fixtures/ephemeral_response/
uri = URI.parse('http://localhost:9876/')
Net::HTTP.get(uri)

# Fixtures are still created for Google
uri = URI.parse('http://www.google.com/')
Net::HTTP.get(uri)

puts "The following directory should only contain a fixture for google"
puts
listing_cmd = %(ls #{File.expand_path(EphemeralResponse::Configuration.fixture_directory)})
puts listing_cmd
puts %x(#{listing_cmd})
