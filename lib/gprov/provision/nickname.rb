# = Class: Nickname
#
# == Overview
#
# implementation of the gprov provisioning nicknameentry
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
require 'gprov/provision/feed'
require 'gprov/provision/entrybase'

class GProv::Provision::Nickname < GProv::Provision::EntryBase

  xmlattr :nickname, :xpath => "apps:nickname/@name"
  xmlattr :login,    :xpath => "apps:login/@userName"

  # Retrieves all nicknames. This can also be restricted to all nicknames for
  # a specific user.
  #
  # Example:
  #
  #   GProv::Provision::Nickname.all(conn) # => all nicknames in the apps domain
  #
  #   GProv::Provision::Nickname.all(conn, :username => 'susy')
  #   # => All nicknames associated with susy
  #
  def self.all(connection, options={})

    url = "/:domain/nickname/2.0"

    if options[:username]
      url << "?username=#{options[:username]}"
    end

    feed = GProv::Provision::Feed.new(connection, url, "/xmlns:feed/xmlns:entry")
    entries = feed.fetch
    entries.map { |xml| new(:status => :clean, :connection => connection, :source => xml) }
  end

  # Retrieves a single nickname
  def self.get(connection, title, options={})
    response = connection.get("/:domain/nickname/2.0/#{title}")
    document = Nokogiri::XML(response.body)
    xml = document.root
    new(:status => :clean, :connection => connection, :source => xml)
  end

  # Generate a nokogiri representation of the nickname
  def to_nokogiri
    base_document = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.entry('xmlns:atom' => 'http://www.w3.org/2005/Atom',
                'xmlns:apps' => 'http://schemas.google.com/apps/2006' ) {

        # Namespaces cannot be used until they are declared, so we need to
        # retroactively declare the namespace of the parent
        xml.parent.namespace = xml.parent.namespace_definitions.select {|ns| ns.prefix == "atom"}.first
        xml.category("scheme" => "http://schemas.google.com/g/2005#kind",
                     "term"   =>"http://schemas.google.com/apps/2006#user")

        xml['apps'].nickname("name"  => @nickname)
        xml['apps'].login("username" => @username)
      }
    end

    base_document
  end

  def create!
    response = connection.post("/:domain/nickname/2.0", {:body => to_nokogiri.to_xml})
    status = :clean
  end

  def delete!
    response = connection.delete("/:domain/nickname/2.0/#{@nickname}")
    status = :deleted
  end
end
