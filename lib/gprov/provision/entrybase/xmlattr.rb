require 'nokogiri'

require 'gprov'
require 'gprov/provision/entrybase'

# Attribute accessors with XML annotations
#
# Defines a data type and provides the logic for extracting and formatting
# object information from xml data.
#
# Attribute accessors are not directly defined, because this class was designed
# to be used DSL style
#
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
class GProv::Provision::EntryBase::XMLAttr

  #
  # The name attribute is not used by this class, but is used by calling
  # classes to determine the method/attribute name they'll use to
  # associate with this object.
  # @return [Symbol]
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

  def access(val=nil)
    @access = val if val
    @access
  end

  # If given a value, set the object type of this method. Returns the type as
  # well, so this acts as a joint setter and getter
  def type(val=nil)
    unless val.nil?
      types = [:numeric, :string, :bool, Array]

      if types.include? val
        @type = val
      else
        raise ArgumentError, "#{val} is not recognized as a valid format type"
      end
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
  #
  # @return [Object] The parsed value
  def parse(xml)
    parsed_string = xml.at_xpath(@xpath).to_s
    parse_to_type(parsed_string)
  end

  private

  # If the attribute has an actual type, then try to coerce the string parsed
  # from XML into that type.
  #
  # @return [Object] The parsed value
  def parse_to_type(str)

    parsed_value = \
    case @type
    when :numeric
      str.to_i
    when :string
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
  # @param [Hash] hash Pairs of attribute names and attribute values to set
  # @example
  #
  #   x = XMLAttr.new(:example, :type => :bool, :xpath => '/my/xpath')
  #
  #   x.type
  #   # => :bool
  #   x.xpath
  #   # => '/my/xpath'
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
