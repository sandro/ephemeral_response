require 'spec_helper'

describe "Integrating with the net" do
  before do
    clear_fixtures
  end

  context "example.com" do
    let(:uri) { URI.parse('http://example.com') }
    it "generates a fixture, then uses the fixture" do
      real_response = Net::HTTP.get(uri)
      fixture = EphemeralResponse::Fixture.new(uri, 'GET')
      File.exists?(fixture.path).should be_true
      Net::HTTP.should_not_receive(:connect_without_ephemeral_response)
      Net::HTTP.should_not_receive(:request_without_ephemeral_response)
      fixture_response = Net::HTTP.get(uri)
      real_response.should == fixture_response
    end

    it "generates a new fixture when the initial fixture expires" do
      Net::HTTP.get(uri)
      old_fixture = EphemeralResponse::Fixture.find(uri, 'GET')
      Time.travel((Time.now + EphemeralResponse::Configuration.expiration * 2).to_s) do
        EphemeralResponse::Fixture.load_all
        Net::HTTP.get(uri)
      end
      new_fixture = EphemeralResponse::Fixture.find(uri, 'GET')
      old_fixture.created_at.should < new_fixture.created_at

      # use the new fixture
      Net::HTTP.should_not_receive(:connect_without_ephemeral_response)
      Net::HTTP.should_not_receive(:request_without_ephemeral_response)
      Net::HTTP.get(uri)
    end
  end
end
