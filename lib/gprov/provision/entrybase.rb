# = gprov/provision/entrybase.rb: base class for provisioning api objects
#
# == Overview
#
# Provides the top level constructs for mapping XML feeds to objects and back
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
require 'gprov/provision/entrybase/classmethods'

class GProv::Provision::EntryBase

  extend GProv::Provision::EntryBase::ClassMethods

  # Status with respect to google.
  # TODO protected?
  # values: :new, :clean, :dirty, :deleted
  attr_reader :status
  attr_reader :connection

  # Instantiates a new entry object.
  #
  # Possible data sources:
  #  * Hash of attribute names and values
  #  * A nokogiri node containing the root of the object
  #  * nothing, as in we have a fresh object.
  def initialize(opts={})

    @status = (opts[:status] || :new)

    if opts[:connection]
      @connection = opts[:connection]
    else
      raise ArgumentError, "#{self.class}.new requires a connection parameter"
    end

    case source = opts[:source]
    when Hash
      attributes_from_hash source
    when Nokogiri::XML::Node
      hash = xml_to_hash(source)
      attributes_from_hash hash
    when NilClass
      # New object!
    else
      raise ArgumentError, "unrecognized object source #{opts[:source]}"
    end
  end

  # Takes all xmlattrs defined against this object, and a given XML
  # document, and converts each xmlattr into the according value.
  def xml_to_hash(xml)
    h = {}
    if attrs = self.class.attributes
      attrs.inject(h) do |hash, attr|
        hash[attr.name] = attr.parse(xml)
        hash
      end
    end
    h
  end

  # Maps hash key/value pairs to object attributes
  def attributes_from_hash(hash)
    hash.each_pair do |k, v|
      if respond_to? "#{k}=".intern
        send("#{k}=".intern, v)
      else
        raise ArgumentError, %Q{Received invalid attribute "#{k}"}
      end
    end
  end
end
