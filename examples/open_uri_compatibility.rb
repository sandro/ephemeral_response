$LOAD_PATH.unshift("lib")
require 'lib/ephemeral_response'
require 'benchmark'
require 'open-uri'

EphemeralResponse::Configuration.expiration = 5
EphemeralResponse.activate

# Run benchmarks against thefuckingweather.com
# The first request takes much longer than the rest
def benchmark_request(number=1)
  uri = URI.parse('http://thefuckingweather.com/?RANDLOC=')
  time = Benchmark.realtime do
    uri.open
  end
  puts "Request #{number} took #{time} secs"
end

5.times {|n| benchmark_request n + 1 }
