# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work PaperOrReport`
module Hyrax
  # Generated form for PaperOrReport
  class PaperOrReportForm < Hyrax::Forms::WorkForm
    self.model_class = ::PaperOrReport

    self.required_fields += [
      :institution
    ]
    self.terms += %i[
      institution
      format
      rights_holder
      creator_orcid
      creator_institutional_relationship
      contributor_orcid
      contributor_institutional_relationship
      contributor_role
      project_name
      funder_name
      funder_awards
      event_title
      event_location
      event_date
      official_link
    ]
    self.terms -= %i[
      description
      access_right
      rights_notes
      subject
      identifier
      based_near
      related_url
      source
    ]
  end
end
