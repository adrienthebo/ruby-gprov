require 'gdata'
require 'gdata/provision/objectbase'
module GData
  class Provision
    class User
      include GData::Provision::ObjectBase

      xml_attr_accessor :title,          :xpath => "title/text()"
      xml_attr_accessor :username,       :xpath => "login/@userName"
      xml_attr_accessor :suspended,      :xpath => "login/@suspended"
      xml_attr_accessor :ip_whitelisted, :xpath => "login/@ipWhitelisted"
      xml_attr_accessor :admin,          :xpath => "login/@admin"
      xml_attr_accessor :change_password_at_next_login, :xpath => "login/@changePasswordAtNextLogin"
      xml_attr_accessor :agreed_to_terms, :xpath => "login/@agreedToTerms"
      xml_attr_accessor :limit,          :xpath => "quota/@limit"
      xml_attr_accessor :family_name,    :xpath => "name/@familyName"
      xml_attr_accessor :given_name,     :xpath => "name/@givenName"

      # Retrieves all users within a domain
      def self.all(provision)
        document = provision.connection.get("/:domain/user/2.0")

        # Namespaces make querying much messier and there's only a single
        # namespace in this document, so we strip it.
        document.remove_namespaces!
        entries = document.xpath("/feed/entry")

        entries.map do |entry|
          hash = xml_to_hash(entry)
          new(hash)
        end

      end

      def self.get(provision, title)
        document = provision.connection.get("/:domain/user/2.0/#{title}")

        puts document.to_xml :indent => 2
      end

      def initialize(options = {})
        options.each_pair do |k, v|
          if respond_to? "#{k}=".intern
            send("#{k}=".intern, v)
          else
            $stderr.puts "Received invalid attribute #{k}"
          end
        end
      end

      # Generate a nokogiri XML representation of this user
      def to_xml
        Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.entry['atom']( 'xmlns:atom' => 'http://www.w3.org/2005/Atom',
                             'xmlns:apps' => 'http://schemas.google.com/apps/2006' ) {
            xml.category('scheme' => 'http://schemas.google.com/g/2005#kind',
                         'term'   => 'http://schemas.google.com/apps/2006#user')
            xml.login['apps']('userName' => @username, 'suspended' => @suspended) # password, hashfunction
            xml.quota['apps']('limit' => @limit)
            xml.name['apps']('familyName' => @family_name, 'givenName' => @given_name)
          }
        end
      end
    end
  end
end
