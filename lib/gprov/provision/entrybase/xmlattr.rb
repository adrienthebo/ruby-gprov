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

    types = [:numeric, :string, :bool, Array]

    if types.include? val
      @type = val
    else
      raise ArgumentError, "#{@type} is not recognized as a valid format type"
    end

    @type
  end

  # Perform input validation against a possible value for this attr
  def valid?(input)
    case @type
    when :numeric
      input.is_a? Numeric
    when :numeric
      input.is_a? String
    when :bool
      # If an object is a boolean, then it will equal a normalized version of
      # itself
      !!input == input
    when Array
      @type.include? input
    else
      # If there's no type set on this attribute, then anything goes
      true
    end
  end

  # Given an XML document, use the supplied xpath value to extract the
  # desired value for this attribute from the document.
  def parse(xml)
    parsed_string = xml.at_xpath(@xpath).to_s
    parse_to_type(parsed_string)
  end

  private

  # If the attribute has an actual type, then try to coerce the string parsed
  # from XML into that type.
  def parse_to_type(str)

    parsed_value = \
    case @type
    when Numeric
      str.to_i
    when String, NilClass
      # No typing specified or actively disabled, just return the object
      str
    when :bool
      str == "true"
    when Array
      str.intern
    else
      str
    end

    @value = parsed_value
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
