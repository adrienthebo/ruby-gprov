# Generic representation of the various types of feeds available from the
# provisioning api
require 'gprov'
require 'nokogiri'

module GProv
  module Provision
    class Feed

      attr_reader :results
      def initialize(connection, path, xpath)
        @connection = connection
        @url        = path
        @xpath      = xpath

        @results = []
      end

      def fetch
        retrieve_page
        @results
      end

      private

      def retrieve_page
        response = @connection.get(@url)

        if response.code == 200
          document = Nokogiri::XML(response.body)
          entries = document.xpath(@xpath)

          @results.concat(entries.to_a)
        else
          raise RuntimeError, "Failed to retrieve #{url}: HTTP #{response.code} #{response.body}"
        end
      end

      def retrieve_all
        raise NotImplementedError
      end

    end
  end
end

