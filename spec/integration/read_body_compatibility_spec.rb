require 'spec_helper'
require 'open-uri'

describe "Read Body Compatibility" do
  include FakeFS::SpecHelpers

  after do
    clear_fixtures
  end

  let(:uri) { URI.parse('http://duckduckgo.com/') }

  def http
    Net::HTTP.new uri.host, uri.port
  end

  def get
    Net::HTTP::Get.new '/'
  end

  def new_post
    Net::HTTP::Post.new('/')
  end

  def send_request(req, body=nil)
    http.start {|h| h.request(req, body) }
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
      begin
      real_response = nil
      http.start do |h|
        h.request(get) do |r|
          r.read_body {|s| real_response = s}
        end
      end
      fixture = EphemeralResponse::Fixture.find(uri, get)
      File.exists?(fixture.path).should be_true
      fixture_response = send_request(get).body
      real_response.should == fixture_response
      rescue Exception => e
        p e
        puts e.backtrace
      end
    end
  end

  context "Net::HTTP.post" do
    it "generates a fixture, then uses the fixture" do
      post = new_post
      post.body = 'foo=bar'

      real_response = nil
      http.post('/', 'foo=bar') {|s| real_response = s}

      fixture = EphemeralResponse::Fixture.find(uri, post)
      File.exists?(fixture.path).should be_true

      fixture_response = send_request(new_post, 'foo=bar').body
      real_response.should == fixture_response
    end
  end
end
