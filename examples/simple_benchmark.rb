$LOAD_PATH.unshift("lib")
require 'rubygems'
require 'lib/ephemeral_response'
require 'benchmark'

EphemeralResponse::Configuration.expiration = 1
EphemeralResponse.activate

def benchmark_request(number=1)
  uri = URI.parse('http://thefuckingweather.com/?RANDLOC=')
  time = Benchmark.realtime do
    Net::HTTP.get(uri)
  end
  puts "Request #{number} took #{time} secs"
end

5.times {|n| benchmark_request n + 1 }
