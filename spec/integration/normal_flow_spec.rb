require 'spec_helper'

describe "Normal flow" do
  include FakeFS::SpecHelpers

  after do
    clear_fixtures
  end

  context "example.com" do
    let(:uri) { URI.parse('http://example.com/') }
    let(:http) { Net::HTTP.new uri.host, uri.port }

    def get
      Net::HTTP::Get.new '/'
    end

    def send_request(req)
      http.start {|h| h.request(req) }
    end

    it "generates a fixture, then uses the fixture" do
      real_response = send_request(get)
      fixture = EphemeralResponse::Fixture.new(uri, get)
      File.exists?(fixture.path).should be_true
      Net::HTTP.should_not_receive(:connect_without_ephemeral_response)
      Net::HTTP.should_not_receive(:request_without_ephemeral_response)
      fixture_response = send_request(get)
      real_response.should == fixture_response
    end

    it "generates a new fixture when the initial fixture expires" do
      send_request(get)
      old_fixture = EphemeralResponse::Fixture.find(uri, get)
      Time.travel((Time.now + EphemeralResponse::Configuration.expiration * 2).to_s) do
        EphemeralResponse::Fixture.load_all
        send_request(get)
      end
      new_fixture = EphemeralResponse::Fixture.find(uri, get)
      old_fixture.created_at.should < new_fixture.created_at

      # use the new fixture
      Net::HTTP.should_not_receive(:connect_without_ephemeral_response)
      Net::HTTP.should_not_receive(:request_without_ephemeral_response)
      send_request(get)
    end

    context "Deactivation" do
      it "doesn't create any fixtures" do
        EphemeralResponse.deactivate
        Net::HTTP.get(uri)
        File.exists?(EphemeralResponse::Configuration.fixture_directory).should be_false
      end

      it "reactivates" do
        EphemeralResponse.deactivate
        Net::HTTP.get(uri)
        File.exists?(EphemeralResponse::Configuration.fixture_directory).should be_false
        EphemeralResponse.activate
        Net::HTTP.get(uri)
        File.exists?(EphemeralResponse::Configuration.fixture_directory).should be_true
      end
    end
  end
end
