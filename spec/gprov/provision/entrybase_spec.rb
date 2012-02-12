require 'spec_helper'
require 'fakeentry'

# Tests are against the fakeentry fixture

describe GProv::Provision::EntryBase do

  [:status, :connection].each do |method|
    it { should respond_to method }
  end
end
