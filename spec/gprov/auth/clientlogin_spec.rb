require 'spec_helper'

describe GProv::Auth::ClientLogin do

  let(:klass) { GProv::Auth::ClientLogin }

  let(:dummy_form) do
    {:body => {
      "accountType" => "HOSTED",
      "Email"       => "test",
      "Passwd"      => "password",
      "service"     => "service",
    }}
  end

  subject { GProv::Auth::ClientLogin.new('test', 'password', 'service') }

  it "should use the google ClientLogin uri" do
    klass.base_uri.should == "https://www.google.com/accounts/ClientLogin"
  end

  it { should respond_to :token }

  describe "when posting" do
    let(:response) { stub :response }

    before :each do
      klass.stubs(:post).with('', dummy_form).returns response
    end

    describe "invalid credentials" do
      before do
        response.stubs(:code).returns 403
      end

      its(:token) { should be_nil }
    end

    describe "valid credentials" do
      before do
        response.stubs(:code).returns 200
        response.stubs(:body).returns "Auth=dummy\n"
      end

      its(:token) { should == "dummy" }
    end
  end
end
