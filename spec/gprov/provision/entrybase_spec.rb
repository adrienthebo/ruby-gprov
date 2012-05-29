require 'spec_helper'
require 'fakeentry'
require 'nokogiri'

# Tests are against the fakeentry fixture

describe GProv::Provision::EntryBase do

  let(:klass) { GProv::Provision::EntryBase }
  let(:connection) { stub 'connection' }

  describe "initialization" do

    it "should fail if a connection is not given" do
      expect { klass.new }.to raise_error ArgumentError, /requires a connection parameter/
    end

    it "should require a connection value" do
      expect { klass.new(:connection => connection) }.to_not raise_error
    end

    it "should accept a status value" do
      obj = klass.new(:connection => connection, :status => :purple)
      obj.status.should == :purple
    end

    describe "from a hash" do
      it "should set attributes from that hash" do
        hash = {:first => :blue, :second => :yellow}

        klass.any_instance.expects(:first=).with(:blue)
        klass.any_instance.expects(:second=).with(:yellow)
        klass.new(:connection => connection, :source => hash)
      end
    end

    describe "from a nokogiri document" do

      before do
        klass.any_instance.stubs(:foo=)
      end

      let(:doc) { Nokogiri::XML::Document.new }
      let(:node) { Nokogiri::XML::Node.new('node', doc) }

      let(:attr) do
        s = stub 'xmlattr'
        s.stubs(:name).returns(:foo)
        s.stubs(:parse).returns(:bar)
        s
      end

      it "should use the class XMLAttrs" do
        klass.expects(:xmlattrs)
        klass.new(:connection => connection, :source => node)
      end

      it "should extract xml attributes" do
        klass.any_instance.expects(:xml_to_hash).returns({})
        klass.any_instance.expects(:attributes_from_hash)
        klass.new(:connection => connection, :source => node)
      end

      it "should use the results for attributes" do
        klass.any_instance.unstub(:foo=)
        klass.any_instance.expects(:foo=).with(:bar)
        klass.expects(:xmlattrs).returns [attr]
        klass.new(:connection => connection, :source => node)
      end

    end
  end

  describe "attributes" do
    subject { klass.new(:connection => connection) }

    [:status, :connection].each do |method|
      it { should respond_to method }
    end
  end
end
