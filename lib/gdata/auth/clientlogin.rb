# Implements the google clientLogin authentication method
require 'net/https'
require 'openssl'
module GData
  module Auth
    class ClientLogin
      def initialize(email, password, service)
        @email    = email
        @password = password
        @service  = service

        @uri = URI.parse('https://www.google.com/accounts/ClientLogin')
      end

      def token
        connection = Net::HTTP.new(@uri.host, @uri.port)
        connection.use_ssl = true
        connection.verify_mode = OpenSSL::SSL::VERIFY_PEER

        request = Net::HTTP::Post.new(@uri.request_uri)
        request.set_form_data({
          "accountType" => "HOSTED",
          "Email"       => @email,
          "Passwd"      => @password,
          "service"     => @service,
        })

        response = connection.request(request)
        if response.code == "200" and response.body =~ /Auth=(.*)\n/
          $1
        end
      end
    end
  end
end
