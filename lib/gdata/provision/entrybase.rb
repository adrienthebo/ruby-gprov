require 'nokogiri'
require 'gdata/provision/entrybase/classmethods'
module GData
  module Provision
    class EntryBase

      extend GData::Provision::EntryBase::ClassMethods
      include GData::Provision::EntryBase::ClassMethods

      #########################################################################
      # The actual base class follows
      #########################################################################

      # Status with respect to google. Feel free to change this if you want
      # to break your code.
      # TODO protected?
      # values: :new, :clean, :dirty, :deleted
      attr_accessor :status
      attr_accessor :connection

      def initialize(source)
        @status = :new
        case source
        when Hash
          attributes_from_hash source
        when Nokogiri::XML::Node
          hash = self.class.xml_to_hash(source) # XXX really?
          attributes_from_hash hash
        else
          raise
        end
      end

      # map this to the class method, for convenience
      def attributes
        self.class.attributes
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
