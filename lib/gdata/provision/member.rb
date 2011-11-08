# Representation of group members
require 'gdata'
require 'gdata/provision/entrybase'

module GData
  module Provision
    class Member
      include GData::Provision::EntryBase

      xml_attr_accessor :member_id, :xpath => ""
      xml_attr_reader   :member_type, :xpath => ""
      xml_attr_reader   :direct_member, :xpath => ""
      

      def to_nokogiri
        base_document = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.entry('xmlns:atom' => 'http://www.w3.org/2005/Atom',
                    'xmlns:apps' => 'http://schemas.google.com/apps/2006',
                    'xmlns:gd'   => "http://schemas.google.com/g/2005" ) {

            # Namespaces cannot be used until they are declared, so we need to
            # retroactively declare the namespace of the parent
            xml.parent.namespace = xml.parent.namespace_definitions.select {|ns| ns.prefix == "atom"}.first

            xml['apps'].property("name" => "memberId", "value" => @member_id)
          }
        end

        base_document
      end
    end
  end
end
