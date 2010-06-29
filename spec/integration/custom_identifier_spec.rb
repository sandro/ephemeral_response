require 'spec_helper'

describe 'Custom Identifiers' do
  let(:uri) { URI.parse("http://localhost:9876/") }
  let(:http) { Net::HTTP.new uri.host, uri.port }
  let(:post) { Net::HTTP::Post.new '/' }

  before do
    clear_fixtures
    post.set_form_data :same => :new
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
    post.set_form_data :same => :different
    http.start {|h| h.request(post) }.body.should == @post_response.body
  end

end
