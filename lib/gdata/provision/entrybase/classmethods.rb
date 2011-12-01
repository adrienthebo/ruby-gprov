require 'nokogiri'
module GData
  module Provision
    class EntryBase
      module ClassMethods

        # The following define attribute readers and writers with an xpath
        # definition for extracting a field from an xml document, and an
        # optional transform parameter to munge the value post extraction

        def xml_attr_reader(name, hash)
          attr_reader name
          save_attribute name, hash
        end

        def xml_attr_writer(name, hash)

          # Manually define our own attr_writer so we can track if any fields
          # have been edited
          define_method("#{name}=") do |val|
            instance_variable_set "@#{name}",   val
            instance_variable_set "@#{status}", :dirty
          end

          save_attribute name, hash
        end

        def xml_attr_accessor(name, hash)
          attr_reader name
          xml_attr_writer name, hash
        end

        # Takes all xml_attr_accessors defined and an xml document and
        # extracts the values from the xml into a hash
        def xml_to_hash(xml)
          @attributes.keys.inject({}) do |hash, key|
            xpath     = @attributes[key][:xpath]
            transform = @attributes[key][:transform]

            value = xml.at_xpath(xpath).to_s
            value = transform.call if transform

            hash[key] = value
            hash
          end
        end

        def attributes
          @attributes.dup unless @attributes.nil?
        end

        private

        def save_attribute(name, attribute_hash)
          @attributes ||= {}
          @attributes[name] = attribute_hash
        end
      end
    end
  end
end
