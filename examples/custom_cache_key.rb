$LOAD_PATH.unshift("lib")
require 'rubygems'
require './lib/ephemeral_response'
require 'benchmark'

EphemeralResponse.configure do |config|
  config.expiration = 1
  config.register('example.com') do |request|
    "#{request.uri.host}#{request.method}#{request.path}"
  end
end

EphemeralResponse.activate

def benchmark_request(number=1)
  uri = URI.parse('http://example.com/')
  time = Benchmark.realtime do
    Net::HTTP.start(uri.host) do |http|
      get = Net::HTTP::Get.new('/')
      get['Date'] = Time.now.to_s
      http.request(get)
    end
  end
  puts "Request #{number} took #{time} secs"
end

5.times {|n| benchmark_request n + 1 }
