require 'nokogiri'

require 'gprov'
require 'gprov/provision/entrybase/classmethods'

#
# This class provides the top level constructs for the Provisioning API
# Entry objects. It handles instantiation and use of the XMLAttr objects.
#
class GProv::Provision::EntryBase

  extend GProv::Provision::EntryBase::ClassMethods

  # The object status with respect to the Provisioning API state.
  # @todo should this be protected?
  # @return [Symbol] One of [:new, :clean, :dirty, :deleted]
  attr_reader :status
  attr_reader :connection

  # Instantiates a new entry object.
  #
  # @param [Hash] opts The datasource and state of this object
  #
  # @option opts [Hash] :source a Hash of attribute names and values
  # @option opts [Nokogiri::XML::Node] :source A nokogiri node containing the root of the object
  # @option opts [NilClass] :source nothing, as in we have a fresh object.
  # @option opts [Connection] :connection The Connection object used to connect to Google
  # @option opts [Symbol] :status (:new) The state of this object.
  def initialize(opts={})

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

    # The last thing we do is mark this object with the given state
    @status = (opts[:status] || :new)
  end

  private

  # Takes all xmlattrs defined against this object, and a given XML
  # document, and converts each xmlattr into the according value.
  def xml_to_hash(xml)
    h = {}
    if attrs = self.class.xmlattrs
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
