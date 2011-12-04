
module GData
  module Provision
    class EntryBase
      class XMLAttr
        attr_reader :name
        def initialize(name, options={})
          @name = name
          methodhash(options)
        end

        def xpath(val=nil)
          @xpath = val if val
          @xpath
        end

        def type(val=nil)

          if [:numeric, :string, :bool].include? val
            @type = val
          else
            raise ArgumentException
          end

          @type
        end

        def parse(xml)
          @value = xml.at_xpath(@xpath).to_s
          format
        end

        private

        def format
          case @type
          when :numeric
            @value = @value.to_i
          when :string
            # o_O
          when :bool
            if @value == "true"
              @value = true
            else # XXX sketchy
              @value = false
            end
          end
          @value
        end

        def methodhash(hash)
          hash.each_pair do |method, value|
            if respond_to? method
              send method, value
            else
              raise ArgumentError, %Q{Received invalid attribute "#{method}"}
            end
          end
        end
      end
    end
  end
end
