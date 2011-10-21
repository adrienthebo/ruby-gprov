module GData
  class Provision
    module EntryBase
      module ClassMethods

        # Defines attribute accessors as well as the xpath definition for
        # extracting the field from an xml document, and an optional
        # transform parameter to munge the value post extration
        def xml_attr_accessor(name, attribute_hash)
          attr_accessor name
          @attributes ||= {}
          @attributes[name] = attribute_hash
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
          @attribute.dup
        end
      end

      def self.included(klass)
        klass.extend ClassMethods
      end

      # Maps hash key/value pairs to object attributes
      def attributes_from_hash(hash)
        hash.each_pair do |k, v|
          if respond_to? "#{k}=".intern
            send("#{k}=".intern, v)
          else
            $stderr.puts %Q{Received invalid attribute "#{k}"}
          end
        end
      end
    end
  end
end
