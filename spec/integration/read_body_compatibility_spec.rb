require 'spec_helper'
require 'open-uri'

describe "Read Body Compatibility" do
  include FakeFS::SpecHelpers

  after do
    clear_fixtures
  end

  let(:uri) { URI.parse('http://example.com/') }

  def http
    Net::HTTP.new uri.host, uri.port
  end

  def get
    Net::HTTP::Get.new '/'
  end

  def send_request(req, data=nil)
    http.start {|h| h.request(req, data) }
  end

  context "open-uri" do
    it "generates a fixture, then uses the fixture" do
      real_response = uri.open.read
      fixture = EphemeralResponse::Fixture.find(uri, get)
      File.exists?(fixture.path).should be_true
      fixture_response = send_request(get).body
      real_response.should == fixture_response
    end
  end

  context "Net::HTTP#get" do
    it "generates a fixture, then uses the fixture" do
      real_response = nil
      http.get('/') {|s| real_response = s}
      fixture = EphemeralResponse::Fixture.find(uri, get)
      File.exists?(fixture.path).should be_true
      fixture_response = send_request(get).body
      real_response.should == fixture_response
    end
  end

  context "Net::HTTP.post" do
    it "generates a fixture, then uses the fixture" do
      post = Net::HTTP::Post.new('/')
      real_response = nil
      http.post('/', 'foo=bar') {|s| real_response = s}
      fixture = EphemeralResponse::Fixture.find(uri, post)
      File.exists?(fixture.path).should be_true
      fixture_response = send_request(post, 'foo=bar').body
      real_response.should == fixture_response
    end
  end
end
