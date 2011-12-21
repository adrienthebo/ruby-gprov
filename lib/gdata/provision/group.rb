# = gdata/provision/group.rb: implementation of the gdata provisioning groupentry
#
# == Overview
#
# implementation of the gdata provisioning groupentry
#
# == Authors
#
# Adrien Thebo
#
# == Copyright
#
# 2011 Puppet Labs
#
require 'gdata'
require 'gdata/provision/entrybase'
require 'gdata/provision/member'
require 'gdata/provision/owner'
module GData
  module Provision
    class Group < GData::Provision::EntryBase

      # TODO copy group_id on instantiation so that groups can change
      # their IDs without exploding
      xmlattr :group_id,          :xpath => %Q{apps:property[@name = "groupId"]/@value}
      xmlattr :group_name,        :xpath => %Q{apps:property[@name = "groupName"]/@value}
      xmlattr :email_permission,  :xpath => %Q{apps:property[@name = "emailPermission"]/@value}
      xmlattr :permission_preset, :xpath => %Q{apps:property[@name = "permissionPreset"]/@value}
      xmlattr :description,       :xpath => %Q{apps:property[@name = "description"]/@value}

      # Retrieves all users within a domain
      def self.all(connection, options={})

        # TODO Fail if unrecognized options passed
        url = "/group/2.0/:domain"
        if member = options[:member]
          url << "/?member=#{member}"

          if direct_only = options[:direct_only]
            url << "&directOnly=#{direct_only}"
          end
        end

        feed = GData::Provision::Feed.new(connection, url, "/xmlns:feed/xmlns:entry")
        entries = feed.fetch
        entries.map { |xml| new(:status => :clean, :connection => connection, :source => xml) }
      end

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
        response = connection.put("/group/2.0/:domain/#{group_id}")
        status = :deleted
      end

      def add_member(membername)
        member = GData::Provision::Member.new(
          :connection => @connection,
          :source => {
            :group_id => @group_id,
            :member_id => membername,
          }
        )
        member.create!
      end

      def del_member(membername)
        member = GData::Provision::Member.new(
          :connection => @connection,
          :source => {
            :group_id => @group_id,
            :member_id => membername,
          }
        )
        member.delete!
      end

      def list_members
        GData::Provision::Member.all(@connection, @group_id)
      end

      def add_owner(ownername)
        owner = GData::Provision::Owner.new(
          :connection => @connection,
          :source => {
            :group_id => @group_id,
            :email => ownername,
          }
        )
        owner.create!
      end

      def del_owner(ownername)
        owner = GData::Provision::Owner.new(
          :connection => @connection,
          :source => {
            :group_id => @group_id,
            :email => ownername,
          }
        )
        owner.delete!
      end

      def list_owners
        GData::Provision::Owner.all(@connection, @group_id)
      end
    end
  end
end
