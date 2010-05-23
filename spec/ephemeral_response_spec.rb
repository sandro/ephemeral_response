require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe EphemeralResponse do
  describe ".activate" do
    it "loads all fixtures" do
      EphemeralResponse::Fixture.should_receive(:load_all)
      EphemeralResponse.activate
    end
  end
end
