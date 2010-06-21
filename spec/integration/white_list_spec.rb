require 'spec_helper'

describe "White Lists" do
  before do
    clear_fixtures
  end

  context "localhost added to white list" do
    let(:uri) { URI.parse('http://localhost:9876/') }
    let(:http) { Net::HTTP.new uri.host, uri.port }
    let(:get) { Net::HTTP::Get.new '/' }

    before do
      EphemeralResponse::Configuration.white_list = "localhost"
    end

    it "doesn't save a fixture" do
      EphemeralResponse::RackReflector.while_running do
        http.start {|h| h.request(get) }
        EphemeralResponse::Fixture.load_all.should be_empty
        Dir.glob("#{EphemeralResponse::Configuration.fixture_directory}/*").should be_empty
      end
    end
  end
end
