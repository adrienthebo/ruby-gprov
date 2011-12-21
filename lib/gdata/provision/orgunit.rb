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
    end
  end
end
