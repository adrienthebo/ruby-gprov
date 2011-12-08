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
      attr_reader :status
      attr_reader :connection

      # Instantiates a new entry object.
      #
      # Possible data sources:
      #  * Hash of attribute names and values
      #  * A nokogiri node containing the root of the object
      def initialize(opts={})

        @status = (opts[:status] || :new)

        if opts[:connection]
          @connection = opts[:connection]
        else
          raise ArgumentError, "#{self.class}.new requires a connection parameter"
        end

        case source = opts[:source]
        when Hash
          attributes_from_hash source
        when Nokogiri::XML::Node
          hash = xml_to_hash(source)
          attributes_from_hash hash
        when NilClass
          # New object!
        else
          raise
        end
      end

      # Takes all xml_attr_accessors defined and an xml document and
      # extracts the values from the xml into a hash.
      def xml_to_hash(xml)
        h = {}
        if attrs = self.class.attributes
          attrs.inject(h) do |hash, attr|
            hash[attr.name] = attr.parse(xml)
            hash
          end
        end
        h
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
