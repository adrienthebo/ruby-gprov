# = gprov/error.rb
#
# == Overview
#
# Common definition of possible gprov errors.
#
# == Authors
#
# Adrien Thebo
#
# == Copyright
#
# 2011 Puppet Labs
#
require 'gprov'
module GProv
  class Error < Exception
    attr_reader :request

    def initialize(request = nil)
      @request = request
    end
    class TokenInvalid < GProv::Error; end
    class InputInvalid < GProv::Error; end
    class QuotaExceeded < GProv::Error; end
  end
end
