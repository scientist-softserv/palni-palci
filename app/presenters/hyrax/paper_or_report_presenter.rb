# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work PaperOrReport`
module Hyrax
  class PaperOrReportPresenter < Hyku::WorkShowPresenter
    delegate :institution,
             :format,
             :rights_holder,
             :creator_orcid,
             :creator_institutional_relationship,
             :contributor_orcid,
             :contributor_institutional_relationship,
             :contributor_role,
             :project_name,
             :funder_name,
             :funder_awards,
             :event_title,
             :event_location,
             :event_date,
             :types,
             :location,
             :official_link, to: :solr_document
  end
end
