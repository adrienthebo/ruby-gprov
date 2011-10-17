# Implements the google clientLogin authentication method
require 'net/http'
require 'openssl'

module GData
  class Connection

    def initialize(email, password, service, options = {})
      @email    = email
      @password = password
      @service  = service

      host = (options[:host] or "apps-api.google.com")
      port = (options[:port] or 443)
      @connection = Net::HTTP.new(host, port)
      @connection.use_ssl = true
      @connection.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    # Authorization is handled by the google clientLogin service
    # perhaps split this out?
    def auth
      request = Net::HTTP::Post.new(URI.parse('https://www.google.com/accounts/ClientLogin'))

      request.set_form_data({
        "accountType" => "HOSTED",
        "Email"       => @email,
        "Passwd"      => @password,
        "service"     => @service,
      })

      # This may not need to be explicit
      request['Content-Type'] = "application/x-www-form-urlencoded"

      response = @connection.request(request)
    end

  end
end
