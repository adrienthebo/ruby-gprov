require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

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

  [:status, :connection].each do |method|
    it "should be added as an instance method when included" do
      @instance.respond_to?(method).should be_true
    end
  end

end

describe GData::Provision::EntryBase::ClassMethods do

  [:xml_attr_accessor, :xml_to_hash, :attributes, :new_from_xml].each do |method|
    it "should be added as a class method when included" do
      FakeEntry.respond_to?(method).should be_true
    end
  end
end

