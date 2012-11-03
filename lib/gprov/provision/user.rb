require 'nokogiri'

require 'gprov'
require 'gprov/provision/feed'
require 'gprov/provision/entrybase'

#
# Implementation of the UserEntry
#
# @see https://developers.google.com/google-apps/provisioning/#managing_user_accounts Google Provisioning API user accounts
class GProv::Provision::User < GProv::Provision::EntryBase

  # The :title attribute is only used after the account has been created
  # TODO implement :none access for attributes. This should be hidden.
  xmlattr :title, :xpath => "xmlns:title/text()"

  xmlattr :user_name,       :xpath => "apps:login/@userName"
  xmlattr :suspended,       :xpath => "apps:login/@suspended",     :type => :bool
  xmlattr :ip_whitelisted,  :xpath => "apps:login/@ipWhitelisted", :type => :bool
  xmlattr :admin,           :xpath => "apps:login/@admin",         :type => :bool
  xmlattr :agreed_to_terms, :xpath => "apps:login/@agreedToTerms", :type => :bool
  xmlattr :limit,           :xpath => "apps:quota/@limit",         :type => :numeric
  xmlattr :family_name,     :xpath => "apps:name/@familyName"
  xmlattr :given_name,      :xpath => "apps:name/@givenName"
  xmlattr :change_password_at_next_login, :xpath => "apps:login/@changePasswordAtNextLogin", :type => :bool

  # Adds explicit ordering to attributes for cleaner output
  def self.attribute_names
    [
      :user_name,
      :given_name,
      :family_name,
      :admin,
      :agreed_to_terms,
      :change_password_at_next_login,
      :suspended,
      :ip_whitelisted,
      :limit
    ]
  end

  # These attributes appear to never be sent from google but can be
  # posted back
  attr_accessor :password, :hash_function_name

  # Retrieves all users within a domain
  #
  # @param [Connection] connection The Connection object used to connect to Google
  #
  # @return [Array<User>] All the fetched user objects
  def self.all(connection)
    feed = GProv::Provision::Feed.new(connection, "/:domain/user/2.0", "/xmlns:feed/xmlns:entry")
    entries = feed.fetch
    entries.map { |xml| new(:status => :clean, :connection => connection, :source => xml) }
  end

  # Fetch a particular user.
  #
  # @param [Connection] connection The Connection object used to connect to Google
  # @param [String] title The nickname to fetch
  # @param [Hash] options This variable is not currently used
  #
  # @return [User]
  def self.get(connection, title, options={})
    response = connection.get("/:domain/user/2.0/#{title}")
    document = Nokogiri::XML(response.body)
    xml = document.root
    new(:status => :clean, :connection => connection, :source => xml)
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
