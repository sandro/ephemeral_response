require 'spec_helper'

module UniqueRequests
  VARIATIONS = %w(
    simple_get
    get_with_query_string
    get_with_query_string_and_basic_auth
    get_with_multiple_headers
    simple_post
    post_with_data
    post_with_body
    post_with_data_and_query_string
    post_with_data_and_query_string_and_basic_auth
    post_with_manual_request_body
  )

  def uri
    @uri ||= URI.parse "http://localhost:#{EphemeralResponse::RackReflector.port}"
  end

  def responses
    @responses ||= {}
  end

  def set_up_responses
    VARIATIONS.each do |request|
      response = send(request)
      if responses.values.include?(response)
        fail "Duplicate response for #{request.inspect}"
      else
        responses[request] = response
      end
    end
  end

  def perform(request, body=nil)
    http = Net::HTTP.new uri.host, uri.port
    # http.set_debug_output $stdout
    http.start do |http|
      http.request(request, body)
    end
  end

  def simple_get
    perform Net::HTTP::Get.new('/foo')
  end

  def get_with_query_string
    perform Net::HTTP::Get.new('/?foo=bar&baz=qux')
  end

  def get_with_query_string_and_basic_auth
    request = Net::HTTP::Get.new('/?foo=bar')
    request.basic_auth 'user', 'password'
    perform request
  end

  def get_with_multiple_headers
    request = Net::HTTP::Get.new('/')
    request['Accept'] = "application/json, text/html"
    request['Accept-Encoding'] = "deflate, gzip"
    perform request
  end

  def simple_post
    perform Net::HTTP::Post.new('/')
  end

  def post_with_data
    request = Net::HTTP::Post.new('/')
    request.set_form_data 'hi' => 'there'
    perform request
  end

  def post_with_body
    request = Net::HTTP::Post.new('/')
    request.body = 'post_with=body'
    perform request
  end

  def post_with_data_and_query_string
    request = Net::HTTP::Post.new('/?foo=bar')
    request.set_form_data 'post_with' => 'data_and_query_string'
    perform request
  end

  def post_with_data_and_query_string_and_basic_auth
    request = Net::HTTP::Post.new('/?foo=bar')
    request.basic_auth 'user', 'password'
    request.set_form_data 'post_with' => 'data_and_query_string_and_basic_auth'
    perform request
  end

  def post_with_manual_request_body
    perform Net::HTTP::Post.new('/'), 'post_with=manual_request_body'
  end

end

describe "Unique fixtures generated for the following requests" do
  include UniqueRequests

  before :all do
    EphemeralResponse.activate
    clear_fixtures
    EphemeralResponse::RackReflector.while_running do
      set_up_responses
    end
  end

  UniqueRequests::VARIATIONS.each do |request|
    it "restores the correct response from the fixture" do
      send(request).body.should == responses[request].body
    end
  end

  context "when querystring has different order" do
    it "restores the correct response" do
      new_response = perform Net::HTTP::Get.new('/?baz=qux&foo=bar')
      new_response.body.should == responses['get_with_query_string'].body
    end
  end

  context "when headers have different order" do
    it "restores the correct response when the headers are exactly reversed" do
      request = Net::HTTP::Get.new('/')
      request['Accept'] = "text/html, application/json"
      request['Accept-Encoding'] = "gzip, deflate"
      new_response = perform request
      new_response.body.should == responses['get_with_multiple_headers'].body
    end

    it "restores the correct response when some headers are reversed" do
      request = Net::HTTP::Get.new('/')
      request['Accept'] = "text/html, application/json"
      request['Accept-Encoding'] = "deflate, gzip"
      new_response = perform request
      new_response.body.should == responses['get_with_multiple_headers'].body
    end
  end

  context "when the http service has not been started" do
    def get
      Net::HTTP::Get.new('/foo/bar/baz')
    end

    it "restores the correct fixture" do
      clear_fixtures
      http = Net::HTTP.new uri.host, uri.port


      EphemeralResponse::RackReflector.while_running do
        http.request(get)
      end

      http.request(get).body.should == EphemeralResponse::Fixture.find(http.uri, get).response.body
    end
  end
end
