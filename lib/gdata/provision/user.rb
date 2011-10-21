require 'gdata'
require 'gdata/provision/objectbase'
module GData
  class Provision
    class User
      include GData::Provision::ObjectBase

      xml_attr_accessor :title,                         :xpath => "entry/title/text()"
      xml_attr_accessor :user_name,                     :xpath => "entry/login/@userName"
      xml_attr_accessor :suspended,                     :xpath => "entry/login/@suspended"
      xml_attr_accessor :ip_whitelisted,                :xpath => "entry/login/@ipWhitelisted"
      xml_attr_accessor :admin,                         :xpath => "entry/login/@admin"
      xml_attr_accessor :change_password_at_next_login, :xpath => "entry/login/@changePasswordAtNextLogin"
      xml_attr_accessor :agreed_to_terms,               :xpath => "entry/login/@agreedToTerms"
      xml_attr_accessor :limit,                         :xpath => "entry/quota/@limit"
      xml_attr_accessor :family_name,                   :xpath => "entry/name/@familyName"
      xml_attr_accessor :given_name,                    :xpath => "entry/name/@givenName"

      # These attributes appear to never be sent from google but can be
      # posted back
      attr_accessor :password, :hash_function_name

      # Retrieves all users within a domain
      def self.all(provision)
        document = provision.connection.get("/:domain/user/2.0")

        # Namespaces make querying much messier and there's only a single
        # namespace in this document, so we strip it.
        document.remove_namespaces!
        entries = document.xpath("/feed")

        entries.map do |entry|
          hash = xml_to_hash(entry)
          new(hash)
        end

      end

      def self.get(provision, title)
        document = provision.connection.get("/:domain/user/2.0/#{title}")
        document.remove_namespaces!

        hash = xml_to_hash(document)

        new(hash)
      end

      def initialize(options = {})
        attributes_from_hash options
      end

      # Generate a nokogiri representation of this user
      def to_nokogiri
        base_document = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.entry('xmlns:atom' => 'http://www.w3.org/2005/Atom',
                    'xmlns:apps' => 'http://schemas.google.com/apps/2006' ) {

            # Namespaces cannot be used until they are declared, so we need to
            # retroactively declare the namespace of the parent
            xml.parent.namespace = xml.parent.namespace_definitions.first
            xml.category("scheme" => "http://schemas.google.com/g/2005#kind",
                         "term"   =>"http://schemas.google.com/apps/2006#user")
            xml['apps'].login(login_attributes)
            xml['apps'].quota("limit" => @limit)
            xml['apps'].name("familyName" => @family_name, "givenName" => @given_name)
          }
        end

        base_document
      end

      def create
      end

      def update
      end

      def delete

      private

      # Map object properties to xml tag attributes
      def login_attributes
        attrs = {
          "userName"                  => @user_name,
          "suspended"                 => @suspended,
          "ipWhitelisted"             => @ip_whitelisted,
          "admin"                     => @admin,
          "changePasswordAtNextLogin" => @change_password_at_next_login,
          "agreedToTerms"             => @agreed_to_terms,
        }

        attrs['password']         = @password unless @password.nil?
        attrs['hashFunctionName'] = @hash_function_name unless @hash_function_name.nil?

        attrs
      end
    end
  end
end
