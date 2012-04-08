require 'spec_helper'

describe EphemeralResponse::Configuration do
  subject { EphemeralResponse::Configuration }

  describe ".debug_output=" do
    it "raises an exception when the argument isn't an IO object" do
      expect do
        subject.debug_output = :foo
      end.to raise_exception(EphemeralResponse::Error, /must respond to #puts/)
    end

    it "stores the argument" do
      subject.debug_output = $stderr
      subject.instance_variable_get(:@debug_output).should == $stderr
    end
  end

  describe ".debug_output" do
    it "defaults to being off (StringIO)" do
      subject.debug_output.should be_instance_of(StringIO)
    end

    it "returns the the result of the setter" do
      subject.debug_output = $stdout
      subject.debug_output.should == $stdout
    end
  end

  describe "#fixture_set" do
    let(:name) { 'name' }

    subject { EphemeralResponse::Configuration.fixture_set }

    it { should be_nil }

    it "can be overwritten" do
      EphemeralResponse::Configuration.fixture_set = name
      should == name
    end
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

  describe "#effective_directory" do
    it "defaults to the fixture directory" do
      subject.effective_directory.should == "spec/fixtures/ephemeral_response"
    end

    context "with a fixture_set" do
      before do
        subject.fixture_directory = "test/fixtures/ephemeral_response"
        subject.fixture_set = :setname
      end

      it "adds the fixture_set to the fixture directory" do
        subject.effective_directory.should == "test/fixtures/ephemeral_response/setname"
      end

      context "that has been reset to the default" do
        before do
          subject.fixture_set = :default
        end

        it "resets to the fixture directory" do
          subject.effective_directory.should == "test/fixtures/ephemeral_response"
        end
      end
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
        subject.expiration = proc { one_day * 7 }
        subject.expiration.should == 604800
      end

      it "raises an error when the return value of the block is not a FixNum" do
        expect do
          subject.expiration = proc { "1 day" }
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

    it "resets the host_registry" do
      subject.register('example.com') {}
      subject.reset
      subject.host_registry.should be_empty
    end

    it "resets debug_output" do
      subject.debug_output = $stderr
      subject.reset
      subject.debug_output.should be_instance_of(StringIO)
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

  describe "#register" do
    it "registers the block for the host" do
      block = Proc.new {}
      subject.register('example.com', &block)
      subject.host_registry['example.com'].should == block
    end
  end
end
