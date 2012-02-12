#!/usr/bin/env ruby -S rspec

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

require 'mocha'
require 'gprov'

RSpec.configure do |config|
  config.mock_with :mocha
end
