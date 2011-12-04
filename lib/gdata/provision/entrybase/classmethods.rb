require 'nokogiri'
require 'gdata/provision/entrybase/xmlattr'
module GData
  module Provision
    class EntryBase
      module ClassMethods

        # The following define attribute readers and writers with an xpath
        # definition for extracting a field from an xml document, and an
        # optional transform parameter to munge the value post extraction

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

        def attributes
          @attrs.map {|a| a.name}.sort_by {|s| s.to_s}
        end

        def attribute_names
          attributes.map {|f| f.to_s.capitalize.sub(/$/, ":").gsub(/_/, " ") }
        end
      end
    end
  end
end
