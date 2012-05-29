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

    attr_reader name

    if attr.access == :write or attr.access.nil?

      # Define an attr_write method that ensures that the input validates
      # against the xmlattr defined type before saving the value. This allows
      # us to do validation client side instead of waiting for Google to send
      # back a failure response.
      #
      # REVIEW: This code contains logic for type enforcement as well as access
      # control and utterly smashes encapsulation. It's tightly coupled with
      # the XMLAttr access method, and that method exists almost entirely for
      # use here. In addition, it's debatable whether validation should occur
      # here or elsehwere.
      #
      # It might make sense to move the entire attr_writer logic created here
      # into the XMLAttr, although I can't determine how to send the data back
      # to the class that's using it.
      define_method("#{name}=") do |val|
        if attr.valid?(val)
          instance_var = "@#{name}".intern
          instance_variable_set instance_var, val
          status = :dirty
        else
          raise ArgumentError, "#{val} is not of type #{attr.type}; cannot set as #{name}"
        end
      end
    end
  end

  # This is a class method because xmlattr objects are not directly
  # exposed, so parsing needs to happen in the class.

  # Provides an ordered list of xml attributes. Mainly used to give
  # a list of attributes in a specific order.
  def xmlattrs
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
