require 'gprov'
require 'gprov/provision/feed'
require 'gprov/provision/entrybase'
require 'gprov/provision/customerid'
require 'gprov/provision/orgmember'

#
# Implements OrganizationUnit
#
# @see https://developers.google.com/google-apps/provisioning/#managing_organization_units Google Provisioning API managing organizational units
class GProv::Provision::OrgUnit < GProv::Provision::EntryBase

  xmlattr :name,                 :xpath => %Q{apps:property[@name = "name"]/@value}
  xmlattr :description,          :xpath => %Q{apps:property[@name = "description"]/@value}
  xmlattr :org_unit_path,        :xpath => %Q{apps:property[@name = "orgUnitPath"]/@value}
  xmlattr :parent_org_unit_path, :xpath => %Q{apps:property[@name = "parentOrgUnitPath"]/@value}
  xmlattr :block_inheritance,    :xpath => %Q{apps:property[@name = "blockInheritance"]/@value}

  # Retrieves all organizational units for a domain
  #
  # @param [Connection] connection The Connection object used to connect to Google
  #
  # @return [Array<OrgUnit>] All the fetched orgunits
  def self.all(connection)
    id = GProv::Provision::CustomerID.get(connection)
    feed = GProv::Provision::Feed.new(connection, "/orgunit/2.0/#{id.customer_id}?get=all", "/xmlns:feed/xmlns:entry")
    entries = feed.fetch
    entries.map { |xml| new(:status => :clean, :connection => connection, :source => xml) }
  end

  # Retrieves a specific orgunit at an orgunit path
  #
  # @param [Connection] connection The Connection object used to connect to Google
  # @param [String] org_path The path to the Organization Unit
  #
  # @return [OrgUnit]
  def self.get(connection, org_path)
    id = GProv::Provision::CustomerID.get(connection)
    response = connection.get("/orgunit/2.0/#{id.customer_id}/#{org_path}")
    document = Nokogiri::XML(response.body)
    xml = document.root

    new(:status => :clean, :connection => connection, :source => xml)
  end

  def to_nokogiri
    base_document = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.entry('xmlns:atom' => 'http://www.w3.org/2005/Atom',
                'xmlns:apps' => 'http://schemas.google.com/apps/2006',
                'xmlns:gd'   => "http://schemas.google.com/g/2005" ) {

        # Namespaces cannot be used until they are declared, so we need to
        # retroactively declare the namespace of the parent
        xml.parent.namespace = xml.parent.namespace_definitions.select {|ns| ns.prefix == "atom"}.first

        xml['apps'].property("name" => "name", "value" => @name)
        xml['apps'].property("name" => "description", "value" => @description)
        xml['apps'].property("name" => "parentOrgUnitPath", "value" => @parent_org_unit_path)
        xml['apps'].property("name" => "blockInheritance", "value" => @block_inheritance)
      }
    end
  end

  def create!
    # xxx cache this?
    id = GProv::Provision::CustomerID.get(connection)
    response = connection.post("/orgunit/2.0/#{id.customer_id}")
    status = :clean
  end

  def update!
    # xxx cache this?
    id = GProv::Provision::Customerid.get(connection)
    response = connection.put("/orgunit/2.0/#{id.customer_id}/#{@org_unit_path}")
    status = :clean
  end

  def delete!
    id = GProv::Provision::Customerid.get(connection)
    response = connection.delete("/orgunit/2.0/#{id.customer_id}/#{@org_unit_path}")
    status = :deleted
  end

  def list_members
    GProv::Provision::OrgMember.all(connection, :target => :orgunit, :orgunit => @org_unit_path)
  end
end
