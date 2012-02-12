require 'spec_helper'

describe GProv::Provision::User do

  [:create!, :update!, :delete].each do |method|
    it { should respond_to method }
  end
end

