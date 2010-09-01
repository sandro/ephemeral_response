require 'spec_helper'

describe Net::HTTP do
  subject { Net::HTTP.new('example.com') }
  let(:request) { Net::HTTP::Get.new("/foo?q=1") }
  let(:uri) { URI.parse("http://example.com/foo?q=1") }
  let(:body) { <<-XML }
    <?xml version="1.0" encoding="utf-8" ?>
    <env:Envelope
       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
      <env:Header>
      </env:Header>
      <env:Body>
        <getClientAccounts xmlns="https://adwords.google.com/api/adwords/v13"></getClientAccounts>
      </env:Body>
    </env:Envelope>
    XML
  let(:response) { OpenStruct.new(:body => "Hello") }

  before do
    subject.stub(:connect_without_ephemeral_response)
    subject.stub(:request_without_ephemeral_response => response)
  end

  describe "#connect" do
    it "does nothing" do
      subject.send(:connect).should be_nil
    end
  end

  describe "#generate_uri" do
    context "when HTTP" do
      subject { Net::HTTP.new('example.com') }

      it "returns the proper http uri object" do
        subject.generate_uri(request).should == URI.parse("http://example.com/foo?q=1")
      end

      it "sets the uri instance variable" do
        subject.generate_uri(request)
        subject.uri.should == URI.parse("http://example.com/foo?q=1")
      end
    end

    context "when HTTPS" do
      subject do
        https = Net::HTTP.new('example.com', 443)
        https.use_ssl = true
        https
      end

      it "returns the proper http uri object" do
        subject.generate_uri(request).should == URI.parse("https://example.com/foo?q=1")
      end
    end
  end

  describe "#request" do
    context "fixture does not exist" do
      before do
        EphemeralResponse::Fixture.stub(:respond_to).and_yield
      end

      it "connects" do
        subject.should_receive(:connect_without_ephemeral_response)
        subject.request(request)
      end

      it "calls #request_without_ephemeral_response" do
        subject.should_receive(:request_without_ephemeral_response).with(request, nil).and_return(response)
        subject.request(request)
      end
    end

    context "fixture exists" do
      before do
        fixture = EphemeralResponse::Fixture.new(uri, request, body) do |f|
          f.response = response
        end
        fixture.register
      end

      after do
        clear_fixtures
      end

      it "does not connect" do
        subject.should_not_receive(:connect_without_ephemeral_response)
        subject.request(request, body)
      end

      it "does not call #request_without_ephemeral_response" do
        subject.should_not_receive(:request_without_ephemeral_response).with(request, nil).and_return(response)
        subject.request(request, body)
      end

      it "yields the response to the block" do
        subject.request(request) do |response|
          response.should == response
        end
      end
    end

    context "connection not started" do
      it "starts the connection" do
        subject.should_not be_started
        subject.request(request)
        subject.should be_started
      end
    end
  end
end
