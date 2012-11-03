require 'gprov'
require 'gprov/provision/entrybase'

# Retrieves a CustomerID string for an accompanying domain.
#
# @example
#
#   cust = GProv::Provision::CustomerID.get(connection)
#   cust.customer_id
#   # => Q3dHFrk7
#   cust.customer_org_unit_name
#   # => "example.com"
#
# @see https://developers.google.com/google-apps/provisioning/#retrieving_a_customerid_experimental CustomerID API specification
#
class GProv::Provision::CustomerID < GProv::Provision::EntryBase

  xmlattr :customer_id, :xpath => %Q{apps:property[@name = "customerId"]/@value}
  xmlattr :name,        :xpath => %Q{apps:property[@name = "name"]/@value}
  xmlattr :description, :xpath => %Q{apps:property[@name = "description"]/@value}

  xmlattr :customer_org_unit_name do
    xpath %Q{apps:property[@name = "customerOrgUnitName"]/@value}
  end

  xmlattr :customer_org_unit_description do
   xpath %Q{apps:property[@name = "customerOrgUnitDescription"]/@value}
  end

  # @param [Connection] connection A Connection object associated with the target domain
  # @param [Hash] options Not currently used
  #
  # @return [CustomerID] The customer ID for the domain
  def self.get(connection, options={})
    response = connection.get("/customer/2.0/customerId")

    document = Nokogiri::XML(response.body)
    xml = document.root

    new(:status => :clean, :connection => connection, :source => xml)
  end
end
