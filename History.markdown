History
=======

0.3.3 / (master)
----------------

#### Bug Fix

* Net::HTTP#request now respects the body parameter. When the body
  parameter is passed in, it will be set on the request (like normal)
  making it available for identification of the fixture. (bernerdschaefer,
  veezus)
* Force removal of expired fixtures to overcome missing file exception

0.3.2 / 2010-07-30
------------------

#### Bug Fix

* Net::HTTP#request now yields the response when a fixture exists
* Net::HTTPResponse#read\_body works when a fixture exists
* OpenURI compatibility (it depends on #read\_body)

0.3.1 / 2010-06-29
--------------

#### Enhancements

* Allow custom matchers by host (leshill)

0.2.1 / 2010-06-24
--------------

#### Enhancements

* Periods no longer replaced with slashes in fixture names.
* Added skip\expiration option allowing fixtures to never expire.

0.2.0 / 2010-06-23
--------------

#### Enhancements

* Fixtures now have use .yml extension instead of .fixture.
* Varying POST data and query strings create new fixtures. Previously, GET /
  and GET /?foo=bar resulted in the same fixture.
* Ability to reset configuration with EphemeralResponse::Configuration.reset
* Ability to white list certain hosts. Responses will not be saved for requests
  made to hosts in the white list.
  Use EphemeralResponse::Configuration.white\_list = "localhost"
* Ephemeral response prints to the Net/HTTP debugger when establishing a
  connection. Set http.set\_debug\_output = $stdout to see when Ephemeral
  Response connects to a host.
