# = gprov/provision/entrybase/xmlattr.rb: attribute accessors with xml annotations
#
# == Overview
#
# Defines a data type and provides the logic for extracting and formatting
# object information from xml data
#
# Attribute accessors are not directly defined, because this class was designed
# to be used DSL style
#
# == Examples
#
#     xmlattr :demo, :type => :numeric, :xpath => "example/xpath/text()"
#
#     xmlattr :demo do
#       type :numeric
#       xpath "example/xpath/text()"
#     end
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

module GProv
  module Provision
    class EntryBase
      class XMLAttr
        attr_reader :name
        def initialize(name, options={})
          @name = name
          @type = :string
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
            raise ArgumentError, "#{@type} is not recognized as a valid format type"
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
            # no op
          when :bool
            if @value == "true"
              @value = true
            else # XXX sketchy
              @value = false
            end
          else
            raise ArgumentError, "Unable to format data: #{@type} is not recognized as a valid format type"
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
