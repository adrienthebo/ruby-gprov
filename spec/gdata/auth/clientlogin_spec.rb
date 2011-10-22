require 'spec_helper'

describe GData::Auth::ClientLogin do

  before :each do
    @klass = GData::Auth::ClientLogin
    @instance = @klass.new('test', 'password', 'service')
    @dummy_form = {:body => {
      "accountType" => "HOSTED",
      "Email"       => "test",
      "Passwd"      => "password",
      "service"     => "service",
    }}
  end

  it "should use the google ClientLogin uri" do
    GData::Auth::ClientLogin.base_uri.should == "https://www.google.com/accounts/ClientLogin"
  end

  it "should have a token method" do
    @instance.respond_to?(:token).should == true
  end

  it "should post valid form data to the uri specified base_uri" do
    stub_response = stub :response
    stub_response.stubs(:code).returns 200
    stub_response.stubs(:body).returns "Auth=dummy\n"
    @klass.expects(:post).with('', @dummy_form).returns stub_response
    @instance.token
  end

  it "should return nil if authorization failed" do
    stub_response = stub :response
    stub_response.stubs(:code).returns 403
    @klass.expects(:post).with('', @dummy_form).returns stub_response
    @instance.token.should be_nil
  end

  it "should return the token if authorization succeeded" do
    stub_response = stub :response
    stub_response.stubs(:code).returns 200
    stub_response.stubs(:body).returns "Auth=dummy\n"
    @klass.expects(:post).with('', @dummy_form).returns stub_response
    @instance.token.should == "dummy"
  end

end
