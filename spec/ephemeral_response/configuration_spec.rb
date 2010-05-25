require 'spec_helper'

describe EphemeralResponse::Configuration do
  subject { EphemeralResponse::Configuration }
  after do
    subject.expiration = lambda { one_day }
  end
  describe "#fixture_directory" do
    it "has a default" do
      subject.fixture_directory.should == "spec/fixtures/ephemeral_response"
    end

    it "can be overwritten" do
      subject.fixture_directory = "test/fixtures/ephemeral_response"
      subject.fixture_directory.should == "test/fixtures/ephemeral_response"
    end
  end

  describe "#expiration" do
    it "defaults to 86400" do
      subject.expiration.should == 86400
    end

    it "can be overwritten" do
      subject.expiration = 43200
      subject.expiration.should == 43200
    end

    context "setting a block" do
      it "returns the value of the block" do
        subject.expiration = lambda { one_day * 7 }
        subject.expiration.should == 604800
      end

      it "raises an error when the return value of the block is not a FixNum" do
        expect do
          subject.expiration = lambda { "1 day" }
        end.to raise_exception(TypeError, "expiration must be expressed in seconds")
      end
    end
  end
end
