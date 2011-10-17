
module GData
  class Provision
    def initialize(domain, token)
      @domain = domain
      @token  = token
    end

    private

    # Note that the actual request logic could possibly extracted into a
    # connection class
  end
end
