# = gdata/auth/clientlogin.rb Implements the google clientLogin authentication method
#
# == Overview
#
# Implements the Google clientLogin method as documented in
# http://code.google.com/apis/accounts/docs/AuthForInstalledApps.html
#
# == Authors
#
# Adrien Thebo
#
# == Copyright
#
# 2011 Puppet Labs
#
require 'httparty'
module GData
  module Auth
    class ClientLogin
      include HTTParty
      base_uri 'https://www.google.com/accounts/ClientLogin'

      # Instantiates a new ClientLogin object.
      #
      # Arguments:
      #  * email: the email account to use for authentication
      #  * password
      #  * service: the Google service to generate authentication for
      #  * options: An additional hash of parameters
      #    * debug: turns on debug information for the request/response
      #
      # TODO make service an optional field
      def initialize(email, password, service, options={})
        @email    = email
        @password = password
        @service  = service
        @options  = options

        # additional options parsing
        if @options[:debug]
          self.class.debug_output $stderr
        end
      end

      # Given an instantiated ClientLogin object, performs the actual 
      # request/response handling of the authentication information.
      #
      # TODO More comprehensive error checking for this.
      # TODO CAPTCHA handling
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
