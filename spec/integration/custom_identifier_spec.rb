require 'spec_helper'

describe 'Custom Identifiers' do
  let(:uri) { URI.parse("http://localhost:9876/") }
  let(:http) { Net::HTTP.new uri.host, uri.port }
  let(:post) { Net::HTTP::Post.new '/' }
  let(:get) { Net::HTTP::Get.new '/' }

  context "with customization based on request body" do
    before do
      clear_fixtures
      post.set_form_data :name => :joe
      EphemeralResponse.configure do |config|
        config.register(uri.host) do |request|
          request.body.split("=").first
        end
      end

      EphemeralResponse::RackReflector.while_running do
        @post_response = http.start {|h| h.request(post) }
      end
    end

    it "returns the same fixture when the post data is slightly different" do
      post.set_form_data :name => :jane
      http.start {|h| h.request(post) }.body.should == @post_response.body
    end
  end

  context "when the customization doesn't match" do
    before do
      clear_fixtures
      EphemeralResponse.configure do |config|
        config.register(uri.host) do |request|
          if Net::HTTP::Post === request
            request.body.split("=").first
          end
        end
      end

      EphemeralResponse::RackReflector.while_running do
        @post_response = http.start {|h| h.request(get) }
      end
    end

    it "falls back to the default identifier and returns the correct fixture" do
      http.start {|h| h.request(get) }.body.should == @post_response.body
    end
  end

end
