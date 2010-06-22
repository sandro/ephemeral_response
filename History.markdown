History
=======

0.2.0 / master
--------------

#### Enhancements

* Fixtures now have use .yml extension instead of .fixture.
* Varying POST data and query strings create new fixtures. Previously, GET /
  and GET /?foo=bar resulted in the same fixture.
* Ability to reset configuration with EphemeralResponse::Configuration.reset
* Ability to white list certain hosts. Responses will not be saved for Requests
  made to hosts in the white list.
  Use EphemeralResponse::Configuration.white_list = "localhost"
* Ephemeral response prints to the Net/HTTP debugger when establishing a
  connection. Just set http.set_debug_output = $stdout to see when Ephemeral
  Response connects to a host.
