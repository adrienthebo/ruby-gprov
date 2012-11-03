require 'httparty'
require 'gprov'
require 'gprov/error'

class GProv::Connection
  # Provides a single point of access for making http requests against the google
  # apps API.
  #
  # This adds the correct authorization header and content-type for make
  # requests against the google API work correctly, so that calling classes
  # don't need to handle authentication, formatting, or basic error handling.
  #

  include HTTParty
  base_uri "https://apps-apis.google.com/a/feeds/"

  attr_reader :domain

  #
  # @param [String] domain
  # @param [String] token
  # @param [hash] options
  #
  # @option options [Boolean] debug Toggles debug output for HTTParty
  # @option options [Boolean] noop  Enables or disables sending actual HTTP queries
  #
  def initialize(domain, token, options = {})
    @domain = domain
    @token  = token
    @options = options

    if @options[:debug]
      self.class.debug_output $stderr
    end
  end

  # Provide the globally required Authorization and Content-Type headers.
  #
  # @return [Hash] The default headers
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

      # Assign default arguments and validate passed arguments
      if path.nil?
        raise ArgumentError, "#{self.class}##{verb} requires a non-nil path"
      end

      # If extra headers were passed in, explode the containing array. Else,
      # create a new empty hash. When that's done, merge the Google API
      # headers.
      case args.length
      when 0 then options = {}
      when 1 then options = args.pop
      else options = *args
      end
      options.merge! default_headers

      # Interpolate the :domain substring into a url to allow for the domain
      # to be in an arbitary position of a request
      path.gsub!(":domain", @domain)

      if options[:noop] or @options[:noop]
        warn "Would have attempted the following call"
        warn "#{verb} #{path} #{options.inspect}"
      else
        # Return the request to the calling class so that the caller can
        # determine the outcome of the request.
        output = self.class.send(verb, path, options)
        case output.code
        when 401
          raise GProv::Error::TokenInvalid.new(output)
        when 403
          raise GProv::Error::InputInvalid.new(output)
        when 503
          raise GProv::Error::QuotaExceeded.new(output)
        else
          if ! output.success?
            raise GProv::Error.new(output)
          else
            output
          end
        end
      end
    end
  end
end
