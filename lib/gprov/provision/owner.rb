# = Class: Owner
#
# == Overview
#
# Represents a group owner.
#
require 'nokogiri'

require 'gprov'
require 'gprov/provision/entrybase'

class GProv::Provision::Owner < GProv::Provision::EntryBase

  xmlattr :email, :xpath => %Q{apps:property[@name = "email"]/@value}
  attr_accessor :group_id

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
