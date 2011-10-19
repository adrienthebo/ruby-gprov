module GData
  module Util
    class XMLMapper

      attr_accessor :xml

      def initialize
        @mappings = []
      end

      def add_mapping(map)
        @mappings << map
      end

      def add_mappings(maps)
        @mappings.concat maps
      end

      def to_hash
        hash = {}

        @mappings.each do |map|
          attribute = map[:attribute]
          xpath     = map[:xpath]
          transform = map[:transform]

          value = xml.at_xpath(xpath).to_s
          value = transform.call if transform

          puts "#{attribute}: #{value}"
          hash[attribute] = value
        end

        hash
      end
    end
  end
end
