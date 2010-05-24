require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe EphemeralResponse do
  describe ".activate" do
    it "loads all fixtures" do
      EphemeralResponse::Fixture.should_receive(:load_all)
      EphemeralResponse.activate
    end
  end

  describe ".deactivate" do
    before do
      Net::HTTP.stub(:alias_method)
    end

    it "restores the original connection method" do
      Net::HTTP.should_receive(:alias_method).with(:connect, :connect_without_ephemeral_response).once
      EphemeralResponse.deactivate
    end

    it "restores the original request method" do
      Net::HTTP.should_receive(:alias_method).with(:request, :request_without_ephemeral_response)
      EphemeralResponse.deactivate
    end

    it "removes #generate_uri" do
      Net::HTTP.instance_methods.sort.should include('generate_uri')
      EphemeralResponse.deactivate
      Net::HTTP.instance_methods.should_not include('generate_uri')
    end
  end
end
