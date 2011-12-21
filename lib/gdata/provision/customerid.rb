# = gdata/customerid.rb
#
# == Overview
#
# Retrieves a customerid string for an accompanying domain
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
require 'gdata/provision/entrybase'
module GData
  module Provision
    class CustomerID < GData::Provision::EntryBase

      xmlattr :customer_id, :xpath => %Q{property[@name = "customerId"]/@value}
      xmlattr :name,        :xpath => %Q{property[@name = "name"]/@value}
      xmlattr :description, :xpath => %Q{property[@name = "description"]/@value}

      xmlattr :customer_org_unit_name, :xpath => %Q{property[@name = "customerOrgUnitName"]/@value}
      xmlattr :customer_org_unit_description, :xpath => %Q{property[@name = "customerOrgUnitDescription"]/@value}
      def self.get(connection, options={})
        response = connection.get("/customer/2.0/customerId")

        document = Nokogiri::XML(response.body)
        document.remove_namespaces!
        xml = document.root

        new(:status => :clean, :connection => connection, :source => xml)
      end
    end
  end
end

