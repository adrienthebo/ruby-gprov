# = gprov/customerid.rb
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
require 'gprov'
require 'gprov/provision/entrybase'
module GProv
  module Provision
    class CustomerID < GProv::Provision::EntryBase

      xmlattr :customer_id, :xpath => %Q{apps:property[@name = "customerId"]/@value}
      xmlattr :name,        :xpath => %Q{apps:property[@name = "name"]/@value}
      xmlattr :description, :xpath => %Q{apps:property[@name = "description"]/@value}

      xmlattr :customer_org_unit_name do
        xpath %Q{apps:property[@name = "customerOrgUnitName"]/@value}
      end

      xmlattr :customer_org_unit_description do
       xpath %Q{apps:property[@name = "customerOrgUnitDescription"]/@value}
      end

      def self.get(connection, options={})
        response = connection.get("/customer/2.0/customerId")

        document = Nokogiri::XML(response.body)
        xml = document.root

        new(:status => :clean, :connection => connection, :source => xml)
      end
    end
  end
end

