require 'httparty'
require 'gprov/auth'

# Implements the Google ClientLogin authentication method.
#
# @see https://developers.google.com/accounts/docs/AuthForInstalledApps API specification
# @see https://github.com/adrienthebo/ruby-gprov/issues/7 ClientLogin deprecation
class GProv::Auth::ClientLogin

  include HTTParty
  base_uri 'https://www.google.com/accounts/ClientLogin'

  # Instantiates a new ClientLogin object.
  #
  # == Parameters
  # @param [String] email The email account to use for authentication
  # @param [String] password The password to use for authentication
  # @param [String] service The Google service for which to generate an auth token
  # @param [Hash] options An additional hash of optional parameters
  #
  # @option options [Boolean] :debug (false) toggles debug information for the request/response
  #
  # @todo make service an optional field
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

  # Given an instantiated ClientLogin object, perform the actual
  # request/response handling of the authentication information.
  #
  # @return [String] If authentication succeeded, the auth token
  # @return [NilClass] If authentication failed, nil
  #
  # @todo More comprehensive error checking
  # @todo CAPTCHA handling
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
