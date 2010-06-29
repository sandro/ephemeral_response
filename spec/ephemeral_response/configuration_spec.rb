require 'spec_helper'

describe EphemeralResponse::Configuration do
  subject { EphemeralResponse::Configuration }

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

  describe "#reset" do
    it "resets expiration" do
      subject.expiration = 1
      subject.expiration.should == 1
      subject.reset

      subject.expiration.should == 86400
    end

    it "resets fixture_directory" do
      subject.fixture_directory = "test/fixtures/ephemeral_response"
      subject.fixture_directory.should == "test/fixtures/ephemeral_response"
      subject.reset

      subject.fixture_directory.should == "spec/fixtures/ephemeral_response"
    end

    it "resets white_list" do
      subject.white_list = 'localhost'
      subject.white_list.should == ['localhost']
      subject.reset

      subject.white_list.should == []
    end

    it "resets skip_expiration" do
      subject.skip_expiration = true
      subject.skip_expiration.should == true
      subject.reset

      subject.skip_expiration.should == false
    end

    it "resets white list after the default has been modified" do
      subject.white_list << "localhost"
      subject.reset
      subject.white_list.should be_empty
    end
  end

  describe "#white_list" do
    it "defaults to an empty array" do
      subject.white_list.should == []
    end

    it "allows hosts to be pushed onto the white list" do
      subject.white_list << 'localhost'
      subject.white_list << 'smackaho.st'
      subject.white_list.should == %w(localhost smackaho.st)
    end
  end

  describe "#white_list=" do
    it "sets a single host" do
      subject.white_list = 'localhost'
      subject.white_list.should == ['localhost']
    end

    it "sets multiple hosts" do
      subject.white_list = 'localhost', 'smackaho.st'
      subject.white_list.should == ['localhost', 'smackaho.st']
    end
  end

  describe "#skip_expiration" do
    it "sets skip_expiration to true" do
      subject.skip_expiration = true
      subject.skip_expiration.should == true
    end

    it "sets skip_expiration to false" do
      subject.skip_expiration = false
      subject.skip_expiration.should == false
    end
  end
end
