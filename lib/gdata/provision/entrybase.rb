require 'nokogiri'
require 'gdata/provision/entrybase/classmethods'
module GData
  module Provision
    class EntryBase

      extend GData::Provision::EntryBase::ClassMethods

      # Status with respect to google. Feel free to change this if you want
      # to break your code.
      # TODO protected?
      # values: :new, :clean, :dirty, :deleted
      attr_accessor :status
      attr_accessor :connection

      def initialize(source=nil)
        @status = :new
        case source
        when Hash
          attributes_from_hash source
        when Nokogiri::XML::Node
          hash = self.class.xml_to_hash(source) # XXX really?
          attributes_from_hash hash
        when NilClass
          # New object!
        else
          raise
        end
      end

      # Maps hash key/value pairs to object attributes
      def attributes_from_hash(hash)
        hash.each_pair do |k, v|
          if respond_to? "#{k}=".intern
            send("#{k}=".intern, v)
          else
            raise ArgumentError, %Q{Received invalid attribute "#{k}"}
          end
        end
      end

    end
  end
end
