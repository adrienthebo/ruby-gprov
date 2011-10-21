require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe GData::Connection do

  before :each do
    @klass = GData::Connection
    @instance = @klass.new("domain", "token")
  end

  it "should use to google apps API url as the base uri" do
    @klass.base_uri.should == "https://apps-apis.google.com/a/feeds"
  end

  [:domain, :token].each do |method|
    it "should have the #{method} accessor" do
      @instance.respond_to?(method).should == true
    end
  end

  describe "http instance method" do
    [:put, :get, :post, :delete].each do |verb|
      describe %Q{"#{verb}"} do
        before do
          xml = %Q{<?xml version="1.0" encoding="UTF-8"?>\n<test xml="pointy"/>}
          @stub_success = mock
          @stub_success.stubs(:code).returns 200
          @stub_success.stubs(:empty?).returns false
          @stub_success.stubs(:body).returns xml

          @stub_failure = mock
          @stub_failure.stubs(:code).returns 403

          @expected_options = {:headers => {
            'Authorization' => "GoogleLogin auth=token",
            'Content-Type' => 'application/atom+xml',
          }}
        end

        it "should be an instance method" do
          @instance.respond_to?(verb).should == true
        end

        it "should be forwarded to the class" do
          @klass.expects(verb).returns @stub_success
          @instance.send(verb, '')
        end

        it "should add the authorization and content-type headers" do

          @klass.expects(verb).with("/url", @expected_options).returns @stub_success
          @instance.send(verb, '/url')
        end

        it "should return a nokogiri document on success" do
          @klass.expects(verb).returns @stub_success
          output = @instance.send(verb, "/url")
          output.is_a?(Nokogiri::XML::Document).should == true
        end
 
        it "should return nil on failure" do
          @klass.expects(verb).returns @stub_failure
          output = @instance.send(verb, "/url")
          output.should be_nil
        end

        it "should interpolate the :domain substring" do
          @klass.expects(verb).with("/domain", @expected_options).returns @stub_success
          @instance.send(verb, "/:domain")
        end
      end
    end
  end
end

