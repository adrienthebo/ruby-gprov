require 'gdata'
require 'gdata/util/xmlmapper'
module GData
  class Provision
    class User

      # Retrieves all users within a domain
      def self.all(provision)
        document = provision.connection.get("/:domain/user/2.0")
        # Namespaces make querying much messier and there's only a single
        # namespace in this document, so we strip it.
        #
        # XXX Move to connection?
        document.remove_namespaces!
        entries = document.xpath("/feed/entry")

        users = []
        users = entries.map do |entry|
          attributes = [
            {:attribute => :title,          :xpath => "title/text()"},
            {:attribute => :username,       :xpath => "login/@userName"},
            {:attribute => :suspended,      :xpath => "login/@suspended"},
            {:attribute => :ip_whitelisted, :xpath => "login/@ipWhitelisted"},
            {:attribute => :admin,          :xpath => "login/@admin"},
            {:attribute => :change_password_at_next_login, :xpath => "login/@changePasswordAtNextLogin"},
            {:attribute => :agreed_to_terms, :xpath => "login/@agreedToTerms"},
            {:attribute => :limit,          :xpath => "quota/@limit"},
            {:attribute => :family_name,    :xpath => "name/@familyName"},
            {:attribute => :given_name,     :xpath => "name/@givenName"},
          ]

          mapper = GData::Util::XMLMapper.new
          mapper.xml = entry
          mapper.add_mappings attributes

          hash = mapper.to_hash
          new(hash)
        end

        users
      end

      attr_accessor :title

      ### apps:login
      attr_accessor :username, :suspended, :ip_whitelisted
      attr_accessor :admin, :change_password_at_next_login, :agreed_to_terms

      ### apps:quota
      attr_accessor :limit

      ### apps:name
      attr_accessor :family_name, :given_name

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
