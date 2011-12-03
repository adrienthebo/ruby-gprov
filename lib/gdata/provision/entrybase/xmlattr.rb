
module GData
  module Provision
    class EntryBase
      class XMLAttr
        attr_reader :name
        def initialize(name)
          @name = name
        end

        def xpath(val=nil)
          @xpath = val if val
          @xpath
        end

        def type(val=nil)

          if [:numeric, :string, :bool].include? val
            @type = val
          else
            raise ArgumentException, 
          end

          @type
        end
      end
    end
  end
end
