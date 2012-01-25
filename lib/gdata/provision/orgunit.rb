# = gdata/provision/orgunit.rb
#
# == Overview
#
# implementation of the gdata organizational unit
#
# == Authors
#
# Adrien Thebo
#
# == Copyright
#
# 2011 Puppet Labs
#
require 'gdata'
require 'gdata/provision/feed'
require 'gdata/provision/entrybase'
require 'gdata/provision/customerid'
require 'gdata/provision/orgmember'
module GData
  module Provision
    class OrgUnit < GData::Provision::EntryBase

      xmlattr :name,                 :xpath => %Q{apps:property[@name = "name"]/@value}
      xmlattr :description,          :xpath => %Q{apps:property[@name = "description"]/@value}
      xmlattr :org_unit_path,        :xpath => %Q{apps:property[@name = "orgUnitPath"]/@value}
      xmlattr :parent_org_unit_path, :xpath => %Q{apps:property[@name = "parentOrgUnitPath"]/@value}
      xmlattr :block_inheritance,    :xpath => %Q{apps:property[@name = "blockInheritance"]/@value}

      def self.all(connection)
        id = GData::Provision::CustomerID.get(connection)
        feed = GData::Provision::Feed.new(connection, "/orgunit/2.0/#{id.customer_id}?get=all", "/xmlns:feed/xmlns:entry")
        entries = feed.fetch
        entries.map { |xml| new(:status => :clean, :connection => connection, :source => xml) }
      end

      def self.get(connection, org_path)
        id = GData::Provision::CustomerID.get(connection)
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

      # POST https://apps-apis.google.com/a/feeds/orgunit/2.0/the customerId
      def create!
        # xxx cache this?
        id = gdata::provision::customerid.get(connection)
        response = connection.post("/orgunit/2.0/#{id.customer_id}")
      end

      def update!
        # xxx cache this?
        id = gdata::provision::customerid.get(connection)
        response = connection.put("/orgunit/2.0/#{id.customer_id}/#{@org_unit_path}")
      end

      def list_members
        GData::Provision::OrgMember.all(connection, @org_unit_path)
      end
    end
  end
end
