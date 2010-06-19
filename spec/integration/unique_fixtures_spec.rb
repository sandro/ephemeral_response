require 'spec_helper'

module UniqueRequests
  VARIATIONS = %w(
    simple_get
    get_with_query_string
    get_with_query_string_and_basic_auth
    simple_post
    post_with_data
    post_with_body
    post_with_data_and_query_string
    post_with_data_and_query_string_and_basic_auth
  )

  def uri
    @uri ||= URI.parse "http://localhost:#{EphemeralResponse::RackReflector.port}"
  end

  def responses
    @responses ||= {}
  end

  def set_up_responses
    EphemeralResponse::RackReflector.start
    VARIATIONS.each do |request|
      responses[request] = send(request)
    end
    EphemeralResponse::RackReflector.stop
  end

  def perform(request)
    http = Net::HTTP.new uri.host, uri.port
    # http.set_debug_output $stdout
    http.start do |http|
      http.request(request)
    end
  end

  def simple_get
    perform Net::HTTP::Get.new('/')
  end

  def get_with_query_string
    perform Net::HTTP::Get.new('/?foo=bar')
  end

  def get_with_query_string_and_basic_auth
    request = Net::HTTP::Get.new('/?foo=bar')
    request.basic_auth 'user', 'password'
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
    request.body = 'hi=there'
    perform request
  end

  def post_with_data_and_query_string
    request = Net::HTTP::Post.new('/?foo=bar')
    request.set_form_data 'hi' => 'there'
    perform request
  end

  def post_with_data_and_query_string_and_basic_auth
    request = Net::HTTP::Post.new('/?foo=bar')
    request.basic_auth 'user', 'password'
    request.set_form_data 'hi' => 'there'
    perform request
  end

end

describe "Unique fixtures generated for the following requests" do
  include UniqueRequests

  before :all do
    EphemeralResponse.activate
    clear_fixtures
    set_up_responses
  end

  UniqueRequests::VARIATIONS.each do |request|
    it "restores the correct response from the fixture" do
      send(request).body.should == responses.fetch(request).body
    end
  end
end
