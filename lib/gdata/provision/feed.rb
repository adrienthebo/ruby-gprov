# Generic representation of the various types of feeds available from the
# provisioning api
require 'gdata'
require 'nokogiri'

module GData
  module Provision
    class Feed

      attr_reader :results
      def initialize(connection, path, xpath)
        @connection  = connection
        @path       = path
        @xpath      = xpath

        @results = []
      end

      def fetch
        retrieve_page
        @results
      end

      private

      def retrieve_page
        response = @connection.get(@path)

        if response.code == 200
          document = Nokogiri::XML(response.body)
          # Stripping out namespaces isn't the best solution, but it's the
          # easiest solution until I can add namespacing to all the xpath defs
          document.remove_namespaces!
          entries = document.xpath(@xpath)

          @results.concat(entries.to_a)
        end
      end

      def retrieve_all
      end

    end
  end
end

