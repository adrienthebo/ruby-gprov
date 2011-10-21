require 'gdata'
require 'gdata/provision/feed'
require 'gdata/provision/entrybase'
module GData
  module Provision
    class User
      include GData::Provision::EntryBase

      # Generic Entry class fields.
      # IGNORE ME
      # list
      # create
      # get
      # update
      # delete

      # The :title attribute is only used after the account has been created
      xml_attr_accessor :title,                         :xpath => "title/text()"

      xml_attr_accessor :user_name,                     :xpath => "login/@userName"
      xml_attr_accessor :suspended,                     :xpath => "login/@suspended"
      xml_attr_accessor :ip_whitelisted,                :xpath => "login/@ipWhitelisted"
      xml_attr_accessor :admin,                         :xpath => "login/@admin"
      xml_attr_accessor :change_password_at_next_login, :xpath => "login/@changePasswordAtNextLogin"
      xml_attr_accessor :agreed_to_terms,               :xpath => "login/@agreedToTerms"
      xml_attr_accessor :limit,                         :xpath => "quota/@limit"
      xml_attr_accessor :family_name,                   :xpath => "name/@familyName"
      xml_attr_accessor :given_name,                    :xpath => "name/@givenName"

      # These attributes appear to never be sent from google but can be
      # posted back
      attr_accessor :password, :hash_function_name

      # Retrieves all users within a domain
      def self.all(connection)
        feed = GData::Provision::Feed.new(connection, "/:domain/user/2.0", "/feed/entry")
        entries = feed.fetch
        entries.map do |xml|
          obj = new_from_xml(xml)
          obj.status = :clean
          obj.connection = connection
          obj
        end
      end

      def self.get(connection, title)
        document = connection.get("/:domain/user/2.0/#{title}")
        document.remove_namespaces!
        entry = document.root

        obj = new_from_xml(entry)
        obj.status = :clean
        obj.connection = connection
        obj
      end

      def initialize(options = {})
        attributes_from_hash options
        @status = :new
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

      def create!
        # TODO Validation?
        response = connection.post("/:domain/user/2.0", {:body => to_nokogiri.to_xml})

        puts response

        # if success
        status = :clean
        # else PANIC
        
      end

      def update!
        response = connection.put("/:domain/user/2.0/#{title}", {:body => to_nokogiri.to_xml})
        pp response
        # if success
        status = :clean
        # else PANIC
      end

      def delete!
        response = connection.delete("/:domain/user/2.0/#{title}")
        pp response
        # if success
        status = :deleted
        # else PANIC
      end

      private

      # Map object properties to xml tag attributes
      def login_attributes
        attrs = {}

        attr_pairs = [
          {"userName"                  => @user_name},
          {"suspended"                 => @suspended},
          {"ipWhitelisted"             => @ip_whitelisted},
          {"admin"                     => @admin},
          {"changePasswordAtNextLogin" => @change_password_at_next_login},
          {"agreedToTerms"             => @agreed_to_terms},
          {'password'                  => @password},
          {'hashFunctionName'          => @hash_function_name},
        ]

        attr_pairs.each do |pair|
          key = pair.keys.first
          attrs.merge!(pair) unless pair[key].nil?
        end

        attrs
      end
    end
  end
end
