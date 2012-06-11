require 'nokogiri'
require 'gprov'
require 'gprov/provision/entrybase'

#
# Implementation of the OwnerEntry
#
# @see https://developers.google.com/google-apps/provisioning/#methods_for_group_owners Google Provisioning API methods for group owners
class GProv::Provision::Owner < GProv::Provision::EntryBase

  xmlattr :email, :xpath => %Q{apps:property[@name = "email"]/@value}
  attr_accessor :group_id

  # Retrieves all owners of a group
  #
  # @param [Connection] connection The Connection object used to connect to Google
  # @param [String] group_id The name of the group to fetch owners for.
  #
  # @return [Array<Owner>] All the fetched owner objects
  def self.all(connection, group_id)
    feed = GProv::Provision::Feed.new(connection, "/group/2.0/:domain/#{group_id}/owner", "/xmlns:feed/xmlns:entry")
    entries = feed.fetch
    entries.map { |xml| new(:status => :clean, :connection => connection, :source => xml) }
  end

  def to_nokogiri
    base_document = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.entry('xmlns:atom' => 'http://www.w3.org/2005/Atom',
                'xmlns:apps' => 'http://schemas.google.com/apps/2006',
                'xmlns:gd'   => "http://schemas.google.com/g/2005" ) {

        # Namespaces cannot be used until they are declared, so we need to
        # retroactively declare the namespace of the parent
        xml.parent.namespace = xml.parent.namespace_definitions.select {|ns| ns.prefix == "atom"}.first

        xml['apps'].property("name" => "email", "value" => @email)
      }
    end

    base_document
  end

  def create!
    response = connection.post("/group/2.0/:domain/#{@group_id}/owner", {:body => to_nokogiri.to_xml})
    status = :clean
  end

  def delete!
    response = connection.delete("/group/2.0/:domain/#{@group_id}/owner/#{@email}")
    status = :clean
  end
end
