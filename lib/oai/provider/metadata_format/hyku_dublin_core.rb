# frozen_string_literal: true

# Override to allow custom OAI export formats (prefixes).
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
          @fields = %i[
            abstract access_right additional_rights_info advisor alternative_title based_near
            bibliographic_citation committee_member contributor contributor_orcid contributor_institutional_relationship
            contributor_role creator creator_institutional_relationship creator_orcid date_created
            date_modified date_uploaded degree department depositor degree_granting_institution
            description discipline event_date event_location event_title format funder_name funder_awards
            identifier institution keyword language level license official_link owner project_name
            publisher related_url resource_type rights_holder rights_notes rights_statement source
            subject title year
          ]
        end

        def encode(model, record)
          xml = Builder::XmlMarkup.new
          map = model.respond_to?("map_#{prefix}") ? model.send("map_#{prefix}") : {}
          xml.tag!(prefix.to_s) do
            fields.each do |field|
              values = value_for(field, record, map)
              next if values.blank?

              if values.respond_to?(:each)
                values.each do |value|
                  xml.tag! field.to_s, value
                end
              else
                xml.tag! field.to_s, values
              end
            end
            # add_public_file_urls(xml, record)
            add_work_url(xml, record)
          end
          xml.target!
        end

        def add_work_url(xml, record)
          work_type = record[:has_model_ssim].first.underscore.pluralize
          if work_type === 'collections'
            work_path = "https://#{Site.instance.account.cname}/#{work_type}/#{record[:id]}"
          else
            work_path = "https://#{Site.instance.account.cname}/concern/#{work_type}/#{record[:id]}"
          end
          xml.tag! 'work_url', work_path
        end

        def add_public_file_urls(xml, record)
          return if record[:file_set_ids_ssim].blank?

          fs_ids = record[:file_set_ids_ssim].join('" OR "')
          public_fs_ids = ActiveFedora::SolrService.query(
            "id:(\"#{fs_ids}\") AND " \
            "has_model_ssim:FileSet AND " \
            "visibility_ssi:#{Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC}",
            fl: ["id"],
            method: :post,
            rows: 1024 # maximum
          )
          return if public_fs_ids.blank?

          public_fs_ids.each do |fs_id_hash|
            file_download_path = "https://#{Site.instance.account.cname}/downloads/#{fs_id_hash['id']}"
            xml.tag! 'file_url', file_download_path
          end
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
