require 'spec_helper'
require 'fakeentry'

describe GProv::Provision::EntryBase::ClassMethods do

  subject { FakeEntry }

  [:xmlattr, :xml_to_hash, :attributes].each do |method|
    it { should respond_to method }
  end

end
