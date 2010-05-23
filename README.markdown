Ephemeral Response
==================

_Save responses from webservices to give your tests a hint of reality._

This is pretty much NetRecorder without the fakeweb dependency.

## Premise

1. run tests
2. all responses are saved to fixtures
3. run tests
4. Return the cached response if it exists and isn't out of date.

   If a cached response exists but is out of date, update it with the real response

   Cache the response if it doesn't exist

## Usage

`$ vi spec/spec_helper.rb`

    require 'ephemeral_response'
    EphemeralResponse.activate

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
