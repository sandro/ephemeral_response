require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe EphemeralResponse do
  describe ".activate" do
    it "deactivates" do
      EphemeralResponse.should_receive(:deactivate)
      EphemeralResponse.activate
    end

    it "starts the proxy server" do
      server = mock(:stop => nil, :running? => false)
      EphemeralResponse.stub(:server => server)
      server.should_receive(:start)
      EphemeralResponse.activate
    end

    it "switches Net::HTTP to return a proxied HTTP class" do
      EphemeralResponse.deactivate
      real_ancestors = Net::HTTP.ancestors
      EphemeralResponse.activate
      Net::HTTP.ancestors.should include(Net::ProxyHTTP)
      Net::OHTTP.ancestors.should == real_ancestors
    end

    it "loads all fixtures" do
      EphemeralResponse::Fixture.should_receive(:load_all)
      EphemeralResponse.activate
    end

  end

  describe ".deactivate" do

    it "stops the proxy server" do
      server = mock(:stop => nil, :running? => false)
      EphemeralResponse.stub(:server => server)
      server.should_receive(:stop)
      EphemeralResponse.deactivate
    end

    it "restores the orignal net http object" do
      EphemeralResponse.deactivate
      Net::HTTP.ancestors.should_not include(Net::ProxyHTTP)
      Net.const_defined?(:OHTTP).should be_false
    end

  end

  describe ".fixtures" do
    it "returns the registered fixtures" do
      EphemeralResponse.fixtures.should == EphemeralResponse::Fixture.fixtures
    end
  end

  describe ".configure" do
    it "yields the configuration object when a block is passed" do
      EphemeralResponse.configure {|c| c.expiration = 1}
      EphemeralResponse::Configuration.expiration.should == 1
    end

    it "returns the configuration object after yielding" do
      EphemeralResponse.configure {}.should == EphemeralResponse::Configuration
    end

    it "returns the configuration object when no block is present" do
      EphemeralResponse.configure.should == EphemeralResponse::Configuration
    end
  end
end
