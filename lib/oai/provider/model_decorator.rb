# frozen_string_literal: true

module OAI
  module Provider
    module ModelDecorator
      # Map Qualified Dublin Core (Terms) fields to PALNI/PALCI fields
      # rubocop:disable Metrics/MethodLength
      def map_oai_hyku
        {
          abstract: :abstract,
          access_right: :access_right,
          accessibility_feature: :accessibility_feature,
          accessibility_hazard: :accessibility_hazard,
          accessibility_summary: :accessibility_summary,
          additional_information: :additional_information,
          advisor: :advisor,
          alternate_version_id: :alternate_version_id,
          alternative_title: :alternative_title,
          audience: :audience,
          based_near: :based_near,
          bibliographic_citation: :bibliographic_citation,
          bulkrax_identifier: :bulkrax_identifier,
          committee_member: :committee_member,
          contributor: :contributor,
          create_date: :create_date,
          creator: :creator,
          date_created: :date_created,
          date_modified: :date_modified,
          date_uploaded: :date_uploaded,
          degree_discipline: :degree_discipline,
          degree_grantor: :degree_grantor,
          degree_level: :degree_level,
          degree_name: :degree_name,
          department: :department,
          depositor: :depositor,
          description: :description,
          discipline: :discipline,
          education_level: :education_level,
          extent: :extent,
          format: :format,
          has_model: :has_model,
          identifier: :identifier,
          import_url: :import_url,
          keyword: :keyword,
          label: :label,
          language: :language,
          learning_resource_type: :learning_resource_type,
          license: :license,
          modified_date: :modified_date,
          newer_version_id: :newer_version_id,
          oer_size: :oer_size,
          owner: :owner,
          previous_version_id: :previous_version_id,
          proxy_depositor: :proxy_depositor,
          publisher: :publisher,
          related_item_id: :related_item_id,
          related_url: :related_url,
          relative_path: :relative_path,
          resource_type: :resource_type,
          rights_holder: :rights_holder,
          rights_notes: :rights_notes,
          rights_statement: :rights_statement,
          source: :source,
          subject: :subject,
          table_of_contents: :table_of_contents,
          title: :title
        }
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end

OAI::Provider::Model.prepend(OAI::Provider::ModelDecorator)