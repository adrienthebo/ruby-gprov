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

require 'gprov'
require 'gprov/provision/entrybase'

class GProv::Provision::EntryBase::XMLAttr

  # The name attribute is not used by this class, but is used by calling
  # classes to determine the method/attribute name they'll use to
  # associate with this object.
  attr_reader :name

  def initialize(name, options={})
    @name = name
    @type = :string
    attributes_from_hash(options)
  end

  def xpath(val=nil)
    @xpath = val if val
    @xpath
  end

  # If given a value, set the object type of this method. Returns the type as
  # well, so this acts as a joint setter and getter
  def type(val=nil)

    types = [:numeric, :string, :bool]

    if types.include? val
      @type = val
    else
      raise ArgumentError, "#{@type} is not recognized as a valid format type"
    end

    @type
  end

  # Given an XML document, use the supplied xpath value to extract the
  # desired value for this attribute from the document.
  def parse(xml)
    @value = xml.at_xpath(@xpath).to_s
    format
  end

  private

  # Convert the given attribute from a string into an actual meaningful
  # type.
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
    end
    @value
  end

  # Given a hash, use the keys as method names and the values as the
  # arguments to send to the method. This allows for quick instantiation
  # of this type.
  #
  # *Example:*
  #
  #   XMLAttr.new(:example, :type => :bool, :xpath => '/my/xpath')
  #
  def attributes_from_hash(hash)
    hash.each_pair do |method, value|
      if respond_to? method
        send method, value
      else
        raise ArgumentError, %Q{Received invalid attribute "#{method}"}
      end
    end
  end
end
