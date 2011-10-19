
require 'gdata'
require 'gdata/connection'
require 'gdata/provision/user'
require 'gdata/provision/group'

module GData
  class Provision
    attr_reader :connection
    def initialize(domain, token)
      @domain = domain
      @token  = token
      @connection = GData::Connection.new(domain, token)
    end
  end
end
