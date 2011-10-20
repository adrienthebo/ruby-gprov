module GData
  class Provision
    module ObjectBase
      module ClassMethods

        def xml_attr_accessor(name, attribute_hash)
          attr_accessor name
          @attributes ||= {}
          @attributes[name] = attribute_hash
        end

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
