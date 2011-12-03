require 'spec_helper'

class FakeEntry < GData::Provision::EntryBase

  xml_attr_accessor :test, :xpath => "/foo/bar/text()"
  xml_attr_accessor :test_transform, :xpath => "/foo/bar/text()", :transform => lambda {|x| x.upcase}
end

describe GData::Provision::EntryBase do

  before do
    @klass = GData::Provision::EntryBase
    @test_klass = FakeEntry
    @instance = @test_klass.new
  end

  describe GData::Provision::EntryBase::ClassMethods do

    [:xml_attr_accessor, :xml_to_hash, :attributes].each do |method|
      it "method #{method} should be a class method" do
        FakeEntry.respond_to?(method).should be_true
      end
    end

    it "xml_attr_accessor should receive a symbol and hash of attributes" do
      @test_klass.attributes[:test].should == {:xpath => "/foo/bar/text()"}
    end

    describe "xml_to_hash" do
    end
  end


  [:status, :connection].each do |method|
    it "method #{method} should be an instance method" do
      @instance.respond_to?(method).should be_true
    end
  end
end
