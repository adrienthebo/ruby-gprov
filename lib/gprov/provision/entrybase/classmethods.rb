require 'nokogiri'

require 'gprov'
require 'gprov/provision/entrybase'
require 'gprov/provision/entrybase/xmlattr'

class GProv::Provision::EntryBase; end

#
# This module provides for the `XMLAttr` DSL for the EntryBase class, and
# exposes the XMLAttrs as class level data for outside consumption.
module GProv::Provision::EntryBase::ClassMethods

  #
  # Generate an XMLAttr for the extending class.
  #
  # @param [Symbol] name The name of this attribute, which will be used to
  #                      create attribute accessors and mutators
  # @param [Hash] options Additional attributes to pass to the XMLAttr constructor
  # @param [Proc] block An optional block to be evaluated in the resulting
  #                     instance context.
  #
  # @return [NilClass]
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

  # @return [Array<XMLAttr>] the XMLAttrs applied to this class.
  def xmlattrs
    @attrs
  end

  # @return [Array<String>] the attribute names of all of the XMLAttrs.
  def attribute_names
    @attrs.map {|a| a.name }
  end

  #
  # Takes the names of the XMLAttrs and turns them into more readable titles.
  # Underscores are replaced with spaces and words are capitalized.
  #
  # @return [Array<String>]
  def attribute_titles
    attribute_names.map {|f| f.to_s.capitalize.sub(/$/, ":").gsub(/_/, " ") }
  end
end
