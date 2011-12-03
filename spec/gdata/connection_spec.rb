require 'spec_helper'

describe GData::Connection do

  before :each do
    @klass = GData::Connection
    @instance = @klass.new("domain", "token")

    @expected_options = {:headers => {
      'Authorization' => "GoogleLogin auth=token",
      'Content-Type' => 'application/atom+xml',
    }}
  end

  it "should use to google apps API url as the base uri" do
    @klass.base_uri.should == "https://apps-apis.google.com/a/feeds"
  end

  it "should have a domain accessor" do
    @instance.respond_to?(:domain).should == true
  end

  it "should expose the default headers" do
    @instance.default_headers.should == @expected_options
  end


  describe "http instance method" do
    [:put, :get, :post, :delete].each do |verb|
      describe %Q{"#{verb}"} do
        before do
          xml = %Q{<?xml version="1.0" encoding="UTF-8"?>\n<test xml="pointy"/>}
          @stub_request = mock
          @stub_request.stubs(:code).returns 200
          @stub_request.stubs(:success?).returns true
          @stub_request.stubs(:class).returns HTTParty::Response
        end

        it "should be an instance method" do
          @instance.respond_to?(verb).should == true
        end

        it "should be forwarded to the class" do
          @klass.expects(verb).returns @stub_request
          @instance.send(verb, '')
        end

        it "should return the http response" do
          @klass.expects(verb).returns @stub_request
          output = @instance.send(verb, "/url")
          output.class.should == HTTParty::Response
        end

        it "should interpolate the :domain substring" do
          @klass.expects(verb).with("/domain", @expected_options).returns @stub_request
          @instance.send(verb, "/:domain")
        end
      end
    end
  end
end

