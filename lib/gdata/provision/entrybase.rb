# = gdata/provision/entrybase.rb: base class for provisioning api objects
#
# == Overview
#
# Provides the top level constructs for mapping XML feeds to objects and back
#
# == Authors
#
# Adrien Thebo
#
# == Copyright
#
# 2011 Puppet Labs
#
require 'nokogiri'
require 'gdata/provision/entrybase/classmethods'
module GData
  module Provision
    class EntryBase

      extend GData::Provision::EntryBase::ClassMethods

      # Status with respect to google.
      # TODO protected?
      # values: :new, :clean, :dirty, :deleted
      attr_accessor :status
      attr_accessor :connection

      # Instantiates a new entry object.
      #
      # Possible data sources:
      #  * Hash of attribute names and values
      #  * A nokogiri node containing the root of the object
      def initialize(source=nil)
        @status = :new
        case source
        when Hash
          attributes_from_hash source
        when Nokogiri::XML::Node
          hash = self.class.xml_to_hash(source)
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
