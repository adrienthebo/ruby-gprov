require 'spec_helper'

describe GProv::Connection do

  let(:klass) { GProv::Connection }

  subject { GProv::Connection.new("domain", "token") }

  let(:expected_options) do
    {:headers => {
      'Authorization' => "GoogleLogin auth=token",
      'Content-Type' => 'application/atom+xml',
    }}
  end

  it "should use to google apps API url as the base uri" do
    klass.base_uri.should == "https://apps-apis.google.com/a/feeds"
  end

  it { should respond_to :domain }

  it "should expose the default headers" do
    subject.default_headers.should == expected_options
  end


  describe "http instance method" do
    [:put, :get, :post, :delete].each do |verb|

      it { should respond_to verb }

      describe "##{verb}" do
        before do
          xml = %Q{<?xml version="1.0" encoding="UTF-8"?>\n<test xml="pointy" />}
          @stub_request = mock
          @stub_request.stubs(:code).returns 200
          @stub_request.stubs(:success?).returns true
          @stub_request.stubs(:class).returns HTTParty::Response
        end


        it "should be forwarded to the class" do
          klass.expects(verb).returns @stub_request
          subject.send(verb, '')
        end

        it "should return the http response" do
          klass.expects(verb).returns @stub_request
          output = subject.send(verb, "/url")
          output.class.should == HTTParty::Response
        end

        it "should interpolate the :domain substring" do
          klass.expects(verb).with("/domain", expected_options).returns @stub_request
          subject.send(verb, "/:domain")
        end

        it "should require a non-nil path" do
          expect {
            subject.send(verb, nil)
          }.to raise_error ArgumentError, /non-nil/
        end
      end
    end
  end
end
