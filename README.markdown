Ephemeral Response
==================

_Save HTTP responses to give your tests a hint of reality._

## Premise

Web responses are volatile. Servers go down, API's change, responses change and
everytime something changes, your tests should fail. Mocking out web responses
may speed up your test suite but the tests essentially become lies. Ephemeral
Response encourages you to run your tests against real web services while
keeping your test suite snappy by caching the responses and reusing them until
they expire.

1. run test suite
2. all responses are saved to fixtures
3. disconnect from the network
4. run test suite

## Example

    require 'benchmark'
    require 'ephemeral_response'

    EphemeralResponse.activate

    5.times do
      puts Benchmark.realtime { Net::HTTP.get "example.com", "/" }
    end

    1.44242906570435     # First request caches the response as a fixture
    0.000689029693603516
    0.000646829605102539
    0.00064396858215332
    0.000645875930786133

## With Rspec

    require 'ephemeral_response'

    Spec::Runner.configure do |config|

      config.before(:suite) do
        EphemeralResponse.activate
      end

      config.after(:suite) do
        EphemeralResponse.deactivate
      end

    end

All responses are cached in yaml files within spec/fixtures/ephemeral\_response.

I'd recommend git ignoring this directory to ensure your tests always hit the
remote service at least once and to prevent credentials (like API keys) from
being stored in your repo.

### Configuration

Change the fixture directory; defaults to "spec/fixtures/ephemeral\_response"

    EphemeralResponse::Configuration.fixture_directory = "test/fixtures/ephemeral_response"

Change the elapsed time for when a fixture will expire; defaults to 24 hours

    EphemeralResponse::Configuration.expiration = 86400 # 24 hours in seconds

Pass a block when setting expiration to gain access to the awesome helper
method `one_day`

    EphemeralResponse::Configuration.expiration = lambda do
      one_day * 30 # Expire in thirty days: 60 * 60 * 24 * 30
    end

Always allow requests to be made to a host by adding it to the white list.
Helpful when running ephemeral response with selenium which makes requests to
the local server.

    EphemeralResponse::Configuration.white_list = "localhost", "smackaho.st"

Never let fixtures expire by setting skip\_expiration to true.

    EphemeralResponse::Configuration.skip_expiration = true

All together now!

    EphemeralResponse.configure do |config|
      config.fixture_directory = "test/fixtures/ephemeral_response"
      config.expiration = lambda { one_day * 30 }
      config.white_list = 'localhost'
      config.skip_expiration = true
    end

## Similar Projects
* [Net Recorder](http://github.com/chrisyoung/netrecorder)
* [Stalefish](http://github.com/jsmestad/stale_fish)
* [VCR](http://github.com/myronmarston/vcr)

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Sandro Turriate. See MIT\_LICENSE for details.
