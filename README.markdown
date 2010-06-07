Ephemeral Response
==================

_Save HTTP responses to give your tests a hint of reality._

This is pretty much NetRecorder without the fakeweb dependency.

## Premise

Web responses are volatile. Servers go down, API's change, responses change and
everytime something changes, your tests should fail. Mocking out web responses
may speed up your test suite but the tests essentially become lies. Ephemeral
Response encourages you to run your tests against real web services while
keeping your test suite snappy by caching the responses and reusing them until
they expire.

1. run tests
2. all responses are saved to fixtures
3. run tests
4.  Return the cached response if it exists and isn't out of date.

    If a cached response exists but is out of date, update it with the real response

    Cache the response if it doesn't exist

## Usage

    $ vi spec/spec_helper.rb

    require 'ephemeral_response'

    Spec::Runner.configure do |config|
      config.before(:suite) do
        EphemeralResponse.activate
      end
      config.after(:suite) do
        EphemeralResponse.deactivate
      end
    end

    $ rake spec

The responses are cached in yaml files within spec/fixtures/ephemeral\_response.

I'd recommend git ignoring this directory to ensure your tests always hit the
remote service at least once and to prevent credentials (like API keys) from
being stored in your repo.

### Configuration

You can change the fixture directory which defaults to "spec/fixtures/ephemeral\_response"

    EphemeralResponse::Configuration.fixture_directory = "test/fixtures/ephemeral\_response"

You can change the elapsed time for when a fixture will expire; defaults to 24 hours

    EphemeralResponse::Configuration.expiration = 86400 # 24 hours in seconds

You can also pass a block when setting expiration which gets instance\_eval'd
giving you access to the awesome helper method `one\_day`

    EphemeralResponse::Configuration.expiration = lambda do
      one_day * 30 # 60 * 60 * 24 * 30
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

Copyright (c) 2010 Sandro Turriate. See LICENSE for details.
