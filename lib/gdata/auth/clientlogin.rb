# Implements the google clientLogin authentication method
require 'httparty'
module GData
  module Auth
    class ClientLogin
      include HTTParty
      base_uri 'https://www.google.com/accounts/ClientLogin'

      def initialize(email, password, service)
        @email    = email
        @password = password
        @service  = service
      end

      def token
        form_data = {
          "accountType" => "HOSTED",
          "Email"       => @email,
          "Passwd"      => @password,
          "service"     => @service,
        }
        response = self.class.post('', {:body => form_data})
        if response.code == 200 and response.body =~ /Auth=(.*)\n/
          $1
        end
      end
    end
  end
end
