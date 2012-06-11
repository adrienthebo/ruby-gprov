require 'nokogiri'
require 'gprov'
require 'gprov/provision/feed'
require 'gprov/provision/entrybase'

#
# Implements an Organization Unit member
#
# @see https://developers.google.com/google-apps/provisioning/#managing_organization_users Google Provisioning API organization user management
class GProv::Provision::OrgMember < GProv::Provision::EntryBase

  # This attribute will only be received and never sent
  xmlattr :org_user_email, :xpath => %Q{apps:property[@name = "orgUserEmail"]/@value}
  xmlattr :org_unit_path,  :xpath => %Q{apps:property[@name = "orgUnitPath"]/@value}

  # Retrieve all organization users in the domain.
  #
  # @param [Connection] connection The Connection object used to connect to Google
  # @param [Hash] options
  #
  # @option options [Symbol] :target (:all) Whether to fetch all users, or that of a single Organization Unit [:orgunit, :all]
  # @option options [String] :orgunit If fetching for an orgunit, fetch for the supplied orgunit
  # The name of the group to fetch owners for.
  #
  # @return [Array<OrgMember>] All the fetched orgmember objects
  def self.all(connection, options = {:target => :all})
    id = GProv::Provision::CustomerID.get(connection)

    case options[:target]
    when :orgunit
      # XXX validation
      url = "/orguser/2.0/#{id.customer_id}?get=children&orgUnitPath=#{options[:orgunit]}"
    when :all
      url = "/orguser/2.0/#{id.customer_id}?get=all"
    end

    feed = GProv::Provision::Feed.new(connection, url, "/xmlns:feed/xmlns:entry")
    entries = feed.fetch
    entries.map { |xml| new(:status => :clean, :connection => connection, :source => xml) }
  end

  # Retrieves a specific organization member
  #
  # @param [Connection] connection The Connection object used to connect to Google
  # @param [String] email The email address of the user to fetch
  #
  # @return [OrgMember]
  def self.get(connection, email)
    id = GProv::Provision::CustomerID.get(connection)
    response = connection.get("/orguser/2.0/#{id.customer_id}/#{email}")

    document = Nokogiri::XML(response.body)
    xml = document.root

    new(:status => :clean, :connection => connection, :source => xml)
  end

  def initialize(opts={})
    super
    # Generate this variable in the case that the org_unit_path is updated
    @old_org_unit_path = @org_unit_path
  end

  def to_nokogiri
    base_document = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.entry('xmlns:atom' => 'http://www.w3.org/2005/Atom',
                'xmlns:apps' => 'http://schemas.google.com/apps/2006',
                'xmlns:gd'   => "http://schemas.google.com/g/2005" ) {

        # Namespaces cannot be used until they are declared, so we need to
        # retroactively declare the namespace of the parent
        xml.parent.namespace = xml.parent.namespace_definitions.select {|ns| ns.prefix == "atom"}.first

        xml['apps'].property("name" => "orgUnitPath", "value" => @org_unit_path)
        xml['apps'].property("name" => "oldOrgUnitPath", "value" => @old_org_unit_path)
      }
    end
  end

  def update!
    id = GProv::Provision::CustomerID.get(connection)
    response = connection.put("/orguser/2.0/#{id.customer_id}/#{@org_user_email}", {:body => to_nokogiri.to_xml})
    status = :clean
  end
end
