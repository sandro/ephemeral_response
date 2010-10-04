require 'spec_helper'

describe "Sets" do
  let(:uri) { URI.parse('http://localhost:9876/') }
  let(:http) { Net::HTTP.new uri.host, uri.port }
  let(:get) { Net::HTTP::Get.new '/' }

  before do
    clear_fixtures
  end

  context "default set" do
    it "saves one fixture to the default directory" do
      EphemeralResponse::RackReflector.while_running do
        http.start {|h| h.request(get) }
        EphemeralResponse::Fixture.fixtures.should_not be_empty
        Dir.glob("#{EphemeralResponse::Configuration.fixture_directory}/*").size.should == 1
      end
    end
  end

  context "named set" do
    let(:name) { 'name' }

    before do
      EphemeralResponse.activate
    end

    after do
      EphemeralResponse::Configuration.reset
    end

    describe "#fixture_set=" do
      it "unloads the existing fixtures" do
        EphemeralResponse::RackReflector.while_running do
          http.start {|h| h.request(get) }
          EphemeralResponse.fixture_set = name
          EphemeralResponse::Fixture.fixtures.should be_empty
        end
      end

      it "reloads any existing fixtures for the set" do
        EphemeralResponse::RackReflector.while_running do
          EphemeralResponse.fixture_set = name
          http.start {|h| h.request(get) }
        end
        EphemeralResponse.fixture_set = :default
        EphemeralResponse.fixture_set = name
        EphemeralResponse::Fixture.find(uri, get).should be
      end
    end

    it "saves one fixture to the set directory only" do
      EphemeralResponse::RackReflector.while_running do
        EphemeralResponse.fixture_set = name
        http.start {|h| h.request(get) }
        EphemeralResponse::Fixture.fixtures.should_not be_empty
        File.exists?("#{EphemeralResponse::Configuration.fixture_directory}/#{name}").should be_true
        Dir.glob("#{EphemeralResponse::Configuration.fixture_directory}/#{name}/*").size.should == 1
      end
    end

    it "reads the fixture back from the set directory" do
      EphemeralResponse::RackReflector.while_running do
        EphemeralResponse.fixture_set = name
        http.start {|h| h.request(get) }
        EphemeralResponse::Fixture.fixtures.should_not be_empty
        File.exists?("#{EphemeralResponse::Configuration.fixture_directory}/#{name}").should be_true
        Dir.glob("#{EphemeralResponse::Configuration.fixture_directory}/#{name}/*").size.should == 1
      end
    end
  end
end
