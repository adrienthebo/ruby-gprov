# Provides a single point of access for making http requests.
require 'rubygems'
require 'httparty'
require 'nokogiri'

module GData
  class Connection
    include HTTParty
    base_uri "https://apps-apis.google.com/a/feeds/"

    attr_reader :domain, :token
    def initialize(domain, token)
      @domain = domain
      @auth = {:headers => {
        'Authorization' => "GoogleLogin auth=#{token}",
        'Content-Type' => 'application/atom+xml',
      }}
    end

    [:put, :get, :post, :delete].each do |verb|
      define_method verb do |path, *args|
        options = *args
        options ||= {}
        options.merge! @auth
        path.gsub!(":domain", @domain)
        output = self.class.send(verb, path, options)
        Nokogiri::XML(output)
      end
    end
  end
end
