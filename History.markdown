History
=======

0.2.0 / master
--------------

#### Enhancements

* Fixtures now have use .yml extension instead of .fixture
* Varying POST data and query strings create new fixtures. Previously, GET /
  and GET /?foo=bar resulting in the same fixture.
* Ability to reset configuration EphemeralResponse::Configuration.reset
* Ability to white list certain hosts meaning their responses won't be saved.
  Use EphemeralResponse::Configuration.white_list = "localhost"
* Ephemeral response will print to the Net/HTTP debugger when establishing a
  connection. Just set http.set_debug_output = $stdout

