require 'gdata'
module GData
  class Error < Exception
    attr_reader :request

    def initialize(request = nil)
      @request = request
    end
    class TokenInvalid < GData::Error; end
    class InputInvalid < GData::Error; end
    class QuotaExceeded < GData::Error; end
  end
end
