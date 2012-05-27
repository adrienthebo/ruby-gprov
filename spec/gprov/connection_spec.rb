require 'spec_helper'

klass = GProv::Connection

describe klass, 'HTTPary' do

  it "should use to google apps API url as the base uri" do
    klass.base_uri.should == "https://apps-apis.google.com/a/feeds"
  end
end

describe klass, "base methods" do

  subject { GProv::Connection.new("domain", "token") }

  let(:expected_options) do
    {:headers => {
      'Authorization' => "GoogleLogin auth=token",
      'Content-Type' => 'application/atom+xml',
    }}
  end

  it { should respond_to :domain }

  it "should expose the default headers" do
    subject.default_headers.should == expected_options
  end

  let(:successful_request) do
    req = stub 'request'
    req.stubs(:code).returns 200
    req.stubs(:success?).returns true
    req
  end

  [:put, :get, :post, :delete].each do |verb|
    describe "method ##{verb}" do
      it { should respond_to verb }

      it "should be forwarded to the class" do
        klass.expects(verb).returns successful_request
        subject.send(verb, '')
      end
    end
  end

  describe 'request processing' do

    it "should interpolate the :domain substring" do
      klass.expects(:get).with("/domain", expected_options).returns successful_request
      subject.send(:get, "/:domain")
    end

    it "should require a non-nil path" do
      expect {
        subject.send(:get, nil)
      }.to raise_error ArgumentError, /non-nil/
    end

    describe "with HTTP return code 200" do
      before do
        klass.stubs(:get).returns successful_request
      end

      it "should not raise an error" do
        subject.send(:get, '/')
      end

      it "should return the http response" do
        output = subject.send(:get, "/url")
        output.should be successful_request
      end
    end

    describe "with HTTP return code 401" do
      let(:noauth) do
        req = stub 'request'
        req.stubs(:code).returns 401
        req
      end

      before do
        klass.stubs(:get).returns noauth
      end

      it "should raise an invalid token error" do
        expect { subject.send(:get, '/') }.to raise_error GProv::Error::TokenInvalid
      end
    end

    describe "with HTTP return code 403" do
      let(:noauth) do
        req = stub 'request'
        req.stubs(:code).returns 403
        req
      end

      before do
        klass.stubs(:get).returns noauth
      end

      it "should raise an invalid input error" do
        expect { subject.send(:get, '/') }.to raise_error GProv::Error::InputInvalid
      end
    end

    describe "with HTTP return code 503" do
      let(:exceeded) do
        req = stub 'request'
        req.stubs(:code).returns 503
        req
      end

      before do
        klass.stubs(:get).returns exceeded
      end

      it "should raise a quota exceeded error" do
        expect { subject.send(:get, '/') }.to raise_error GProv::Error::QuotaExceeded
      end
    end

    describe "with any other HTTP status code" do

      describe "that is successful" do
        let(:ok) do
          req = stub 'request'
          req.stubs(:code).returns 201
          req.stubs(:success?).returns true
          req
        end

        before do
          klass.stubs(:get).returns ok
        end

        it "should not raise an error" do
          expect { subject.send(:get, '/') }.to_not raise_error
        end
      end

      describe "that is not successful" do
        let(:nok) do
          req = stub 'request'
          req.stubs(:code).returns 404
          req.stubs(:success?).returns false
          req
        end

        before do
          klass.stubs(:get).returns nok
        end

        it "should raise an error" do
          expect { subject.send(:get, '/') }.to raise_error GProv::Error
        end
      end
    end
  end
end
