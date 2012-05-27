# = gprov/provision/entrybase/classmethods.rb
#
# == Overview
#
# Generates the DSL style behavior for entrybase and adds some convenience
# methods
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
require 'gprov/provision/entrybase/xmlattr'

# Predeclare this.
class GProv::Provision::EntryBase; end

module GProv::Provision::EntryBase::ClassMethods
  # Generates xmlattrs and encapsulates parsing logic
  def xmlattr(name, options={}, &block)
    attr = GProv::Provision::EntryBase::XMLAttr.new(name, options)
    attr.instance_eval &block if block_given?
    @attrs ||= []
    @attrs << attr
    attr_accessor name
  end

  # This is a class method because xmlattr objects are not directly
  # exposed, so parsing needs to happen in the class.

  # Provides an ordered list of xml attributes. Mainly used to give
  # a list of attributes in a specific order.
  def attributes
    @attrs
  end

  def attribute_names
    @attrs.map {|a| a.name }
  end

  # Transforms standard ruby attribute names to something slightly more
  # human readable.
  def attribute_titles
    attribute_names.map {|f| f.to_s.capitalize.sub(/$/, ":").gsub(/_/, " ") }
  end
end
