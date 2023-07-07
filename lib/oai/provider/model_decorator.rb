# frozen_string_literal: true

module OAI
  module Provider
    module ModelDecorator
      # Map Qualified Dublin Core (Terms) fields to PALNI/PALCI fields
      def map_oai_hyku # rubocop:disable Metrics/MethodLength
        {
          abstract: :abstract,
          access_right: :access_right,
          additional_rights_info: :additional_rights_info,
          advisor: :advisor,
          alternative_title: :alternative_title,
          based_near: :based_near,
          bibliographic_citation: :bibliographic_citation,
          committee_member: :committee_member,
          contributor: :contributor,
          contributor_institutional_relationship: :contributor_institutional_relationship,
          contributor_orcid: :contributor_orcid,
          contributor_role: :contributor_role,
          creator: :creator,
          creator_institutional_relationship: :creator_institutional_relationship,
          creator_orcid: :creator_orcid,
          date_created: :date_created,
          date_modified: :date_modified,
          date_uploaded: :date_uploaded,
          degree: :degree,
          degree_granting_institution: :degree_granting_institution,
          department: :department,
          depositor: :depositor,
          description: :description,
          discipline: :discipline,
          event_date: :event_date,
          event_location: :event_location,
          event_title: :event_title,
          format: :format,
          funder_name: :funder_name,
          funder_awards: :funder_awards,
          identifier: :identifier,
          institution: :institution,
          keyword: :keyword,
          language: :language,
          # level: :level,
          license: :license,
          official_link: :official_link,
          owner: :owner,
          project_name: :project_name,
          publisher: :publisher,
          related_url: :related_url,
          resource_type: :resource_type,
          rights_holder: :rights_holder,
          rights_notes: :rights_notes,
          rights_statement: :rights_statement,
          source: :source,
          subject: :subject,
          title: :title,
          year: :year
        }
      end
    end
  end
end

OAI::Provider::Model.prepend(OAI::Provider::ModelDecorator)
