require 'spec_helper'

describe EphemeralResponse::Fixture do
  include FakeFS::SpecHelpers

  let(:fixture_directory) { File.expand_path EphemeralResponse::Configuration.fixture_directory }
  let(:request) { Net::HTTP::Get.new '/' }
  let(:uri) { URI.parse("http://example.com/") }
  let(:fixture) { EphemeralResponse::Fixture.new(uri, request) { |f| f.response = "hello world"} }

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
          FileUtils.touch %w(1.yml 2.yml)
        end
      end

      it "calls #load_fixture for each fixture file" do
        EphemeralResponse::Fixture.should_receive(:load_fixture).with("#{fixture_directory}/1.yml")
        EphemeralResponse::Fixture.should_receive(:load_fixture).with("#{fixture_directory}/2.yml")
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
    context "host included in white list" do
      before do
        EphemeralResponse::Configuration.white_list = uri.host
      end

      it "returns flow back to net/http" do
        2.times do
          EphemeralResponse::Fixture.respond_to(fixture.uri, request) do
            :real_net_request
          end.should == :real_net_request
        end
      end
    end

    context "fixture loaded" do
      it "returns the fixture response" do
        fixture.save
        EphemeralResponse::Fixture.load_all
        response = EphemeralResponse::Fixture.respond_to(fixture.uri, request)
        response.should == "hello world"
      end
    end

    context "fixture not loaded" do
      it "sets the response to the block" do
        EphemeralResponse::Fixture.respond_to(fixture.uri, request) do
          "new response"
        end
        EphemeralResponse::Fixture.fixtures[fixture.identifier].response.should == "new response"
      end

      it "saves the fixture" do
        EphemeralResponse::Fixture.respond_to(fixture.uri, request) do
          "new response"
        end
        File.exists?(fixture.path).should be_true
      end
    end
  end

  describe "#identifier" do
    let(:request) { Net::HTTP::Get.new '/' }
    let(:uri) { URI.parse "http://example.com/" }
    subject { EphemeralResponse::Fixture.new uri, request }

    it "hashes the full url with request yaml" do
      hash = Digest::SHA1.hexdigest("#{uri}#{request.to_yaml}")
      subject.identifier.should == hash
    end
  end
end
