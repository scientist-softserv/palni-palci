# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work PaperOrReport`
module Hyrax
  # Generated form for PaperOrReport
  class PaperOrReportForm < Hyrax::Forms::WorkForm
    self.model_class = ::PaperOrReport
    include PdfFormBehavior

    self.required_fields += %i[
      institution
      resource_type
      types
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
      video_embed
      resource_type
      types
    ]

    self.terms = %i[title location alternative_title creator contributor description abstract
                    keyword subject license rights_statement publisher date_created
                    resource_type institution types language format rights_holder
                    creator_orcid creator_institutional_relationship
                    contributor_orcid contributor_institutional_relationship
                    contributor_role
                    project_name
                    funder_name funder_awards event_title event_location event_date
                    official_link identifier based_near access_right rights_notes
                    related_url video_embed
                    representative_id thumbnail_id rendering_ids files
                    visibility_during_embargo embargo_release_date visibility_after_embargo
                    visibility_during_lease lease_expiration_date visibility_after_lease
                    visibility ordered_member_ids source in_works_ids
                    member_of_collection_ids admin_set_id]

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

    def primary_terms
      super - %i[video_embed] + %i[license]
    end
  end
end
