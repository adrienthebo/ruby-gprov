require 'gdata'
require 'gdata/util/xmlmapper'
module GData
  class Provision
    class Group

      # Retrieves all users within a domain
      def self.all(provision)
        document = provision.connection.get("/group/2.0/:domain")
        # Namespaces make querying much messier and there's only a single
        # namespace in this document, so we strip it.
        #
        # XXX Move to connection?
        document.remove_namespaces!
        entries = document.xpath("/feed/entry")

        groups = []
        groups = entries.map do |entry|
          attributes = [
            {:attribute => :group_id, :xpath => %Q{property[@name = "groupId"]/@value}},
            {:attribute => :group_name, :xpath => %Q{property[@name = "groupName"]/@value}},
            {:attribute => :email_permission, :xpath => %Q{property[@name = "emailPermission"]/@value}},
            {:attribute => :permission_preset, :xpath => %Q{property[@name = "permissionPreset"]/@value}},
            {:attribute => :description, :xpath => %Q{property[@name = "description"]/@value}},
          ]

          mapper = GData::Util::XMLMapper.new
          mapper.xml = entry
          mapper.add_mappings attributes

          hash = mapper.to_hash
          new(hash)
        end

        groups
      end

      attr_accessor :group_id, :group_name, :email_permission, :permission_preset, :description
      def initialize(options = {})
        options.each_pair do |k, v|
          if respond_to? "#{k}=".intern
            send("#{k}=".intern, v)
          else
            $stderr.puts "Received invalid attribute #{k}"
          end
        end
      end
    end
  end
end

