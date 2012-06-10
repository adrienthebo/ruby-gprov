require 'nokogiri'
require 'gprov'
require 'gprov/provision/entrybase'
require 'gprov/provision/member'
require 'gprov/provision/owner'

#
# Implementation of the GroupEntry
#
# @see https://developers.google.com/google-apps/provisioning/#methods_for_groups Google Provisioning API methods for groups
class GProv::Provision::Group < GProv::Provision::EntryBase

  # TODO copy group_id on instantiation so that groups can change
  # their IDs without exploding
  xmlattr :group_id,          :xpath => %Q{apps:property[@name = "groupId"]/@value}
  xmlattr :group_name,        :xpath => %Q{apps:property[@name = "groupName"]/@value}
  xmlattr :email_permission,  :xpath => %Q{apps:property[@name = "emailPermission"]/@value}
  xmlattr :permission_preset, :xpath => %Q{apps:property[@name = "permissionPreset"]/@value}
  xmlattr :description,       :xpath => %Q{apps:property[@name = "description"]/@value}

  # Retrieves all groups within a domain
  #
  # @param [Connection] connection The Connection object used to connect to Google
  # @param [Hash] options The datasource and state of this object
  #
  # @option opts [String] :member Restrict the query to only groups of the given user
  # @option opts [Boolean] :direct_only Restrict the query to only direct group membership
  #
  # @return [Array<Group>] All the fetched group objects
  def self.all(connection, options={})

    # TODO Fail if unrecognized options passed
    url = "/group/2.0/:domain"
    if member = options[:member]
      url << "/?member=#{member}"

      if direct_only = options[:direct_only]
        url << "&directOnly=#{direct_only}"
      end
    end

    feed = GProv::Provision::Feed.new(connection, url, "/xmlns:feed/xmlns:entry")
    entries = feed.fetch
    entries.map { |xml| new(:status => :clean, :connection => connection, :source => xml) }
  end

  # Fetch a single group.
  #
  # @param [Connection] connection The Connection object used to connect to Google
  # @param [String] group_id The name of the group to fetch
  #
  # @return [Group]
  def self.get(connection, group_id)
    response = connection.get("/group/2.0/:domain/#{group_id}")
    document = Nokogiri::XML(response.body)
    xml = document.root

    new(:status => :clean, :connection => connection, :source => xml)
  end

  def to_nokogiri
    base_document = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.entry('xmlns:atom' => 'http://www.w3.org/2005/Atom',
                'xmlns:apps' => 'http://schemas.google.com/apps/2006',
                'xmlns:gd'   => "http://schemas.google.com/g/2005" ) {

        # Namespaces cannot be used until they are declared, so we need to
        # retroactively declare the namespace of the parent
        xml.parent.namespace = xml.parent.namespace_definitions.select {|ns| ns.prefix == "atom"}.first
        xml.category("scheme" => "http://schemas.google.com/g/2005#kind",
                     "term"   =>"http://schemas.google.com/apps/2006#user")

        xml['apps'].property("name" => "groupId",         "value" => @group_id)
        xml['apps'].property("name" => "groupName",       "value" => @group_name)
        xml['apps'].property("name" => "emailPermission", "value" => @email_permission)
        xml['apps'].property("name" => "description",     "value" => @description)
      }
    end

    base_document
  end

  def create!
    response = connection.post("/group/2.0/:domain", {:body => to_nokogiri.to_xml})
    status = :clean
  end

  def update!
    response = connection.put("/group/2.0/:domain", {:body => to_nokogiri.to_xml})
    status = :clean
  end

  def delete!
    response = connection.delete("/group/2.0/:domain/#{group_id}")
    status = :deleted
  end

  def add_member(membername)
    member = GProv::Provision::Member.new(
      :connection => @connection,
      :source => {
        :group_id => @group_id,
        :member_id => membername,
      }
    )
    member.create!
  end

  def del_member(membername)
    member = GProv::Provision::Member.new(
      :connection => @connection,
      :source => {
        :group_id => @group_id,
        :member_id => membername,
      }
    )
    member.delete!
  end

  def list_members
    GProv::Provision::Member.all(@connection, @group_id)
  end

  def add_owner(ownername)
    owner = GProv::Provision::Owner.new(
      :connection => @connection,
      :source => {
        :group_id => @group_id,
        :email => ownername,
      }
    )
    owner.create!
  end

  def del_owner(ownername)
    owner = GProv::Provision::Owner.new(
      :connection => @connection,
      :source => {
        :group_id => @group_id,
        :email => ownername,
      }
    )
    owner.delete!
  end

  def list_owners
    GProv::Provision::Owner.all(@connection, @group_id)
  end
end
