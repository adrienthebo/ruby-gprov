require 'gdata'
require 'gdata/provision/entrybase'
require 'gdata/provision/member'
module GData
  module Provision
    class Group < GData::Provision::EntryBase

      xmlattr :group_id,          :xpath => %Q{property[@name = "groupId"]/@value}
      xmlattr :group_name,        :xpath => %Q{property[@name = "groupName"]/@value}
      xmlattr :email_permission,  :xpath => %Q{property[@name = "emailPermission"]/@value}
      xmlattr :permission_preset, :xpath => %Q{property[@name = "permissionPreset"]/@value}
      xmlattr :description,       :xpath => %Q{property[@name = "description"]/@value}

      # Retrieves all users within a domain
      def self.all(connection)
        feed = GData::Provision::Feed.new(connection, "/group/2.0/:domain", "/feed/entry")
        entries = feed.fetch
        entries.map { |xml| new(:status => :clean, :connection => connection, :source => xml) }
      end

      def self.get(connection, group_id)
        response = connection.get("/group/2.0/:domain/#{group_id}")

        document = Nokogiri::XML(response.body)
        document.remove_namespaces!
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
        status = :clean
      end

      def add_member(member)
        member = GData::Provision::Member.new(:member_id => member)
        member.connection = @connection
        member.group_id = @group_id
        member.create!
      end

      def del_member(member)
        member = GData::Provision::Member.new(:member_id => member)
        member.connection = @connection
        member.group_id = @group_id
        member.delete!
      end

      def list_members
        GData::Provision::Member.all(@connection, @group_id)
      end
    end
  end
end
