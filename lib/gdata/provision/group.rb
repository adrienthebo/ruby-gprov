require 'gdata'
require 'gdata/provision/objectbase'
module GData
  class Provision
    class Group
      include GData::Provision::ObjectBase

      xml_attr_accessor :group_id, :xpath => %Q{property[@name = "groupId"]/@value}
      xml_attr_accessor :group_name, :xpath => %Q{property[@name = "groupName"]/@value}
      xml_attr_accessor :email_permission, :xpath => %Q{property[@name = "emailPermission"]/@value}
      xml_attr_accessor :permission_preset, :xpath => %Q{property[@name = "permissionPreset"]/@value}
      xml_attr_accessor :description, :xpath => %Q{property[@name = "description"]/@value}

      # Retrieves all users within a domain
      def self.all(provision)
        document = provision.connection.get("/group/2.0/:domain")

        # Namespaces make querying much messier and there's only a single
        # namespace in this document, so we strip it.
        document.remove_namespaces!
        entries = document.xpath("/feed/entry")

        entries.map do |entry|
          hash = xml_to_hash(entry)
          new(hash)
        end
      end

      def initialize(options = {})
        attributes_from_hash options
      end
    end
  end
end

