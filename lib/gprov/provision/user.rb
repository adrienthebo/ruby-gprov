# = gprov/provision/user.rb: implementation of the gprov provisioning userentry
#
# == Overview
#
# implementation of the gprov provisioning userentry
#
# == Authors
#
# Adrien Thebo
#
# == Copyright
#
# 2011 Puppet Labs
#
require 'nokogiri'

require 'gprov'
require 'gprov/provision/feed'
require 'gprov/provision/entrybase'

class GProv::Provision::User < GProv::Provision::EntryBase

  # The :title attribute is only used after the account has been created
  # TODO implement :none access for attributes. This should be hidden.
  xmlattr :title, :type => :string, :xpath => "xmlns:title/text()"

  xmlattr :user_name,       :xpath => "apps:login/@userName"
  xmlattr :suspended,       :xpath => "apps:login/@suspended"
  xmlattr :ip_whitelisted,  :xpath => "apps:login/@ipWhitelisted"
  xmlattr :admin,           :xpath => "apps:login/@admin"
  xmlattr :agreed_to_terms, :xpath => "apps:login/@agreedToTerms"
  xmlattr :limit,           :xpath => "apps:quota/@limit"
  xmlattr :family_name,     :xpath => "apps:name/@familyName"
  xmlattr :given_name,      :xpath => "apps:name/@givenName"
  xmlattr :change_password_at_next_login, :xpath => "apps:login/@changePasswordAtNextLogin"

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
  def self.all(connection)
    feed = GProv::Provision::Feed.new(connection, "/:domain/user/2.0", "/xmlns:feed/xmlns:entry")
    entries = feed.fetch
    entries.map { |xml| new(:status => :clean, :connection => connection, :source => xml) }
  end

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
