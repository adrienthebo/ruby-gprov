require 'gdata'
require 'gdata/provision/feed'
require 'gdata/provision/entrybase'
module GData
  module Provision
    class User < GData::Provision::EntryBase

      # Generic Entry class fields.
      # IGNORE ME
      # list
      # create
      # get
      # update
      # delete

      # The :title attribute is only used after the account has been created
      xmlattr :title, :type => :string, :xpath => "title/text()"

      xmlattr :user_name,       :type => :string, :xpath => "login/@userName"
      xmlattr :suspended,       :type => :string, :xpath => "login/@suspended"
      xmlattr :ip_whitelisted,  :type => :string, :xpath => "login/@ipWhitelisted"
      xmlattr :admin,           :type => :string, :xpath => "login/@admin"
      xmlattr :agreed_to_terms, :type => :string, :xpath => "login/@agreedToTerms"
      xmlattr :limit,           :type => :string, :xpath => "quota/@limit"
      xmlattr :family_name,     :type => :string, :xpath => "name/@familyName"
      xmlattr :given_name,      :type => :string, :xpath => "name/@givenName"
      xmlattr :change_password_at_next_login, :type => :string, :xpath => "login/@changePasswordAtNextLogin"

      # These attributes appear to never be sent from google but can be
      # posted back
      attr_accessor :password, :hash_function_name

      # Retrieves all users within a domain
      def self.all(connection)
        feed = GData::Provision::Feed.new(connection, "/:domain/user/2.0", "/feed/entry")
        entries = feed.fetch
        entries.map do |xml|
          obj = new(xml)
          obj.status = :clean
          obj.connection = connection
          obj
        end
      end

      def self.get(connection, title)
        response = connection.get("/:domain/user/2.0/#{title}")

        document = Nokogiri::XML(response.body)
        document.remove_namespaces!
        entry = document.root

        obj = new(entry)
        obj.status = :clean
        obj.connection = connection
        obj
      end

      # Generate a nokogiri representation of this user
      def to_nokogiri
        base_document = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.entry('xmlns:atom' => 'http://www.w3.org/2005/Atom',
                    'xmlns:apps' => 'http://schemas.google.com/apps/2006' ) {

            # Namespaces cannot be used until they are declared, so we need to
            # retroactively declare the namespace of the parent
            xml.parent.namespace = xml.parent.namespace_definitions.select {|ns| ns.prefix == "atom"}.first
            xml.category("scheme" => "http://schemas.google.com/g/2005#kind",
                         "term"   =>"http://schemas.google.com/apps/2006#user")
            xml['apps'].login(login_attributes)
            xml['apps'].quota("limit" => @limit) if @limit
            xml['apps'].name("familyName" => @family_name, "givenName" => @given_name)
          }
        end

        base_document
      end

      def create!
        response = connection.post("/:domain/user/2.0", {:body => to_nokogiri.to_xml})
        status = :clean
      end

      def update!
        response = connection.put("/:domain/user/2.0/#{title}", {:body => to_nokogiri.to_xml})
        status = :clean
      end

      def delete!
        response = connection.delete("/:domain/user/2.0/#{title}")
        status = :deleted
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
