require 'gprov'
class GProv::Error < Exception
  # Common definition of possible gprov errors.

  attr_reader :request

  def initialize(request = nil)
    @request = request
  end

  # Raised when the requesting user is not authenticated, IE has an invalid
  # token
  class TokenInvalid < GProv::Error; end

  # Raised when a request is malformed
  class InputInvalid < GProv::Error; end

  # Raised when the Google Apps request quota is exceeded
  class QuotaExceeded < GProv::Error; end
end
