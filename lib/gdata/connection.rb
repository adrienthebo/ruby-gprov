# Provides a single point of access for making http requests.
#
# This adds the correct authorization header and content-type for make
# requests against the google API work correctly
require 'rubygems'
require 'httparty'
require 'nokogiri'
require 'gdata/error'

module GData
  class Connection
    include HTTParty
    base_uri "https://apps-apis.google.com/a/feeds/"

    attr_reader :domain
    def initialize(domain, token, options = {})
      @domain = domain
      @token  = token
      @options = options

      if @options[:debug]
        self.class.debug_output $stderr
      end
    end

    def default_headers
      {:headers => {
        'Authorization' => "GoogleLogin auth=#{@token}",
        'Content-Type'  => 'application/atom+xml',
      }}
    end

    # Forward instance level http methods to the class, after adding
    # authorization and content-type information.
    [:put, :get, :post, :delete].each do |verb|
      define_method verb do |path, *args|

        options = *args
        options ||= {}
        options.merge! default_headers

        # Interpolate the :domain substring into a url to allow for the domain
        # to be in an arbitary position of a request
        path.gsub!(":domain", @domain)

        if options[:noop] or @options[:noop]
          $stderr.puts "Would have attempted the following call"
          $stderr.puts "#{verb} #{path} #{options.inspect}"
        else
          # Return the request to the calling class so that the caller can
          # determine the outcome of the request.
          output = self.class.send(verb, path, options)
          case output.code
          when 401
            raise GData::Error::TokenInvalid
          when 403
            raise GData::Error::InputInvalid
          when 503
            raise GData::Error::QuotaExceeded
          else
            if output.success?
              output
            else
              raise
            end
          end
        end
      end
    end
  end
end
