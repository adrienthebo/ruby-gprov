require 'spec_helper'
require 'fakeentry'

# Tests are against the fakeentry fixture

describe GProv::Provision::EntryBase do

  let(:klass) { GProv::Provision::EntryBase }

  describe "initialization" do

    it "should require a connection" do
      expect { klass.new }.to raise_error ArgumentError, /requires a connection parameter/
    end
  end

  describe "basic methods" do
    let(:connection) { stub 'connection' }
    subject { klass.new(:connection => connection) }

    [:status, :connection].each do |method|
      it { should respond_to method }
    end
  end
end
