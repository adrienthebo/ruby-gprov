require 'spec_helper'

class FakeEntry
  include GData::Provision::EntryBase

  xml_attr_accessor :test, :xpath => "/foo/bar/text()"
  xml_attr_accessor :test_transform, :xpath => "/foo/bar/text()", :transform => lambda {|x| x.upcase}
end

describe GData::Provision::EntryBase do

  before do
    @klass = FakeEntry
    @instance = @klass.new
  end

  describe GData::Provision::EntryBase::ClassMethods do

    [:xml_attr_accessor, :xml_to_hash, :attributes, :new_from_xml].each do |method|
      it "method #{method} should be a class method when #{@klass} is included" do
        FakeEntry.respond_to?(method).should be_true
      end
    end
  end


  [:status, :connection].each do |method|
    it "method #{method} should be an instance method when #{@klass} is included" do
      @instance.respond_to?(method).should be_true
    end
  end
end
