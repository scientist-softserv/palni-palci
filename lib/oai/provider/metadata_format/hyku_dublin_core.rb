# frozen_string_literal: true

module OAI
  module Provider
    module MetadataFormat
      class HykuDublinCore < OAI::Provider::Metadata::Format
        def initialize
          @prefix = 'oai_hyku'
          @schema = 'http://dublincore.org/schemas/xmls/qdc/dcterms.xsd'
          @namespace = 'http://purl.org/dc/terms/'
          @element_namespace = 'hyku'

          # Dublin Core Terms Fields
          # For new fields, add here first then add to #map_oai_hyku
          # TODO: ensure these are all "public" fields
          @fields = %i[
            abstract access_right accessibility_feature accessibility_hazard accessibility_summary
            additional_information advisor alternate_version_id alternative_title audience based_near
            bibliographic_citation bulkrax_identifier committee_member contributor create_date
            creator date_created date_modified date_uploaded degree_discipline degree_grantor
            degree_level degree_name department depositor description discipline education_level
            extent format has_model identifier import_url keyword label language learning_resource_type
            license modified_date newer_version_id oer_size owner previous_version_id proxy_depositor
            publisher related_item_id related_url relative_path resource_type rights_holder
            rights_notes rights_statement source subject table_of_contents title
          ]
        end

        # Override to strip namespace and header out
        def encode(model, record)
          xml = Builder::XmlMarkup.new
          map = model.respond_to?("map_#{prefix}") ? model.send("map_#{prefix}") : {}
          xml.tag!(prefix.to_s) do
            fields.each do |field|
              values = value_for(field, record, map)
              if values.respond_to?(:each)
                values.each do |value|
                  xml.tag! field.to_s, value
                end
              else
                xml.tag! field.to_s, values
              end
            end
          end
          xml.target!
        end

        def header_specification
          {
            'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
            'xmlns:oai_hyku' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
            'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
            'xmlns:dcterms' => "http://purl.org/dc/terms/",
            'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
            'xsi:schemaLocation' => "http://dublincore.org/schemas/xmls/qdc/dcterms.xsd"
          }
        end
      end
    end
  end
end

OAI::Provider::Base.register_format(OAI::Provider::MetadataFormat::HykuDublinCore.instance)
