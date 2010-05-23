require 'spec_helper'

describe EphemeralResponse::Fixture do
  let(:fixture_directory) { File.expand_path EphemeralResponse::Configuration.fixture_directory }
  let(:uri) { URI.parse("http://example.com") }
  let(:fixture) { EphemeralResponse::Fixture.new(uri, 'GET') { |f| f.response = "hello world"} }

  before do
    clear_fixtures
  end

  describe ".load_all" do
    it "returns the empty fixtures hash when the fixture directory doesn't exist" do
      EphemeralResponse::Fixture.should_not_receive :load_fixture
      EphemeralResponse::Fixture.load_all.should == {}
    end

    it "clears old fixtures" do
      EphemeralResponse::Fixture.should_receive(:clear)
      EphemeralResponse::Fixture.load_all
    end

    context "fixture files exist" do
      before do
        FileUtils.mkdir_p fixture_directory
        Dir.chdir(fixture_directory) do
          FileUtils.touch %w(1.fixture 2.fixture)
        end
      end

      it "calls #load_fixture for each fixture file" do
        EphemeralResponse::Fixture.should_receive(:load_fixture).with("#{fixture_directory}/1.fixture")
        EphemeralResponse::Fixture.should_receive(:load_fixture).with("#{fixture_directory}/2.fixture")
        EphemeralResponse::Fixture.load_all
      end
    end
  end

  describe ".load_fixture" do
    context "fixture expired" do
      before do
        fixture.instance_variable_set(:@created_at, Time.new - (EphemeralResponse::Configuration.expiration * 2))
        fixture.save
      end

      it "removes the fixture" do
        EphemeralResponse::Fixture.load_all
        File.exists?(fixture.path).should be_false
      end

      it "does not add the fixture in the fixtures hash" do
        EphemeralResponse::Fixture.load_all
        EphemeralResponse::Fixture.fixtures.should_not have_key(fixture.identifier)
      end
    end

    context "fixture not expired" do
      before do
        fixture.save
      end

      it "adds the the fixture to the fixtures hash" do
        EphemeralResponse::Fixture.load_all
        EphemeralResponse::Fixture.fixtures[fixture.identifier].should == fixture
      end
    end
  end

  describe ".respond_to" do
    context "fixture loaded" do
      it "returns the fixture response" do
        fixture.save
        EphemeralResponse::Fixture.load_all
        response = EphemeralResponse::Fixture.respond_to(fixture.uri, fixture.method)
        response.should == "hello world"
      end
    end

    context "fixture not loaded" do
      it "sets the response to the block" do
        EphemeralResponse::Fixture.respond_to(fixture.uri, fixture.method) do
          "new response"
        end
        EphemeralResponse::Fixture.fixtures[fixture.identifier].response.should == "new response"
      end

      it "saves the fixture" do
        EphemeralResponse::Fixture.respond_to(fixture.uri, fixture.method) do
          "new response"
        end
        File.exists?(fixture.path).should be_true
      end
    end
  end
end
