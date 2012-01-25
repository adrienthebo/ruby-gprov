# = gdata/provision/orgmember.rb
#
# == Overview
#
# Representation of the members of organizational units
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
module GData
  module Provision
    class OrgMember < GData::Provision::EntryBase

      # This attribute will only be received and never sent
      xmlattr :org_user_email, :xpath => %Q{apps:property[@name = "orgUserEmail"]/@value}
      xmlattr :org_unit_path,  :xpath => %Q{apps:property[@name = "orgUnitPath"]/@value}

      # Retrieve all organization users in the domain.
      def self.all(connection, options = {:target => :all})
        id = GData::Provision::CustomerID.get(connection)

        case options[:target]
        when :orgunit
          # XXX validation
          url = "/orguser/2.0/#{id.customer_id}?get=children&orgUnitPath=#{options[:orgunit]}"
        when :all
          url = "/orguser/2.0/#{id.customer_id}?get=all"
        end

        feed = GData::Provision::Feed.new(connection, url, "/xmlns:feed/xmlns:entry")
        entries = feed.fetch
        entries.map { |xml| new(:status => :clean, :connection => connection, :source => xml) }
      end

      def self.get(connection, email)
        id = GData::Provision::CustomerID.get(connection)
        response = connection.get("/orguser/2.0/#{id.customer_id}/#{email}")

        document = Nokogiri::XML(response.body)
        xml = document.root

        new(:status => :clean, :connection => connection, :source => xml)
      end

      # This attribute will only be sent and never received
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

            xml['apps'].property("name" => "orgUserPath", "value" => @org_user_path)
            xml['apps'].property("name" => "oldOrgUserPath", "value" => @old_org_user_path)
          }
        end
      end
    end
  end
end

