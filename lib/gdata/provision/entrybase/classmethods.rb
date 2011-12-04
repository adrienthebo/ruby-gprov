# = gdata/provision/entrybase/classmethods.rb
#
# == Overview
#
# Generates the DSL style behavior for entrybase and adds some convenience
# methods
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
require 'gdata/provision/entrybase/xmlattr'
module GData
  module Provision
    class EntryBase
      module ClassMethods
        # Generates xmlattrs and encapsulates parsing logic
        def xmlattr(name, options={} &block)
          attr = GData::Provision::EntryBase::XMLAttr.new(name, options)
          attr.instance_eval &block if block_given?
          @attrs ||= []
          @attrs << attr
          attr_accessor name
        end

        # Takes all xml_attr_accessors defined and an xml document and
        # extracts the values from the xml into a hash
        def xml_to_hash(xml)
          h = {}
          if @attrs
            @attrs.inject(h) do |hash, attr|
              hash[attr.name] = attr.parse(xml)
              hash
            end
          end
          h
        end

        # Provides an ordered list of xml attributes. Mainly used to give
        # a list of attributes in a specific order.
        def attributes
          @attrs.map {|a| a.name}.sort_by {|s| s.to_s}
        end


        # Transforms standard ruby attribute names to something slightly more
        # human readable.
        def attribute_names
          attributes.map {|f| f.to_s.capitalize.sub(/$/, ":").gsub(/_/, " ") }
        end
      end
    end
  end
end
