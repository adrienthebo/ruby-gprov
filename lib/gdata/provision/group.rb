require 'gdata'
require 'gdata/provision/entrybase'
module GData
  class Provision
    class Group
      include GData::Provision::EntryBase

      xml_attr_accessor :group_id, :xpath => %Q{property[@name = "groupId"]/@value}
      xml_attr_accessor :group_name, :xpath => %Q{property[@name = "groupName"]/@value}
      xml_attr_accessor :email_permission, :xpath => %Q{property[@name = "emailPermission"]/@value}
      xml_attr_accessor :permission_preset, :xpath => %Q{property[@name = "permissionPreset"]/@value}
      xml_attr_accessor :description, :xpath => %Q{property[@name = "description"]/@value}

      # Retrieves all users within a domain
      def self.all(connection)
        feed = GData::Provision::Feed.new(connection, "/group/2.0/:domain", "/feed/entry")
        entries = feed.fetch
        entries.map {|xml| new_from_xml(xml) }
      end

      def self.get(connection, group_id)
        document = connection.get("/group/2.0/:domain/#{group_id}")
        document.remove_namespaces!
        entry = document.root

        new_from_xml(entry)
      end

      def initialize(options = {})
        attributes_from_hash options
      end
    end
  end
end

