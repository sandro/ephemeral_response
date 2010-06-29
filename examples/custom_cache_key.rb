$LOAD_PATH.unshift("lib")
require 'rubygems'
require 'lib/ephemeral_response'
require 'benchmark'

EphemeralResponse::Configuration.expiration = 15
EphemeralResponse.activate

EphemeralResponse.configure do |config|
  config.register('example.com') do |request|
    "#{request.method}#{request.path}"
  end
end

def benchmark_request(number=1)
  uri = URI.parse('http://example.com/')
  time = Benchmark.realtime do
    Net::HTTP.start(uri.host) do |http|
      get = Net::HTTP::Get.new('/')
      get['Date'] = Time.now.to_s
      http.request(get)
    end
  end
  sleep 1
  puts "Request #{number} took #{time} secs"
end

5.times {|n| benchmark_request n + 1 }
