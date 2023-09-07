# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated form for Etd
  class EtdForm < Hyrax::Forms::WorkForm
    self.model_class = ::Etd
    self.required_fields += %i[
      year
      abstract
      resource_type
      institution
      degree
      degree_granting_institution
      types
      subject
    ]
    self.terms += %i[
      year
      video_embed
      institution
      resource_type
      additional_rights_info
      bibliographic_citation
      format
      degree
      discipline
      degree_granting_institution
      advisor
      committee_member
      department
      types
    ]

    self.terms = %i[title alternative_title creator contributor description abstract
                    keyword subject rights_statement publisher advisor
                    committee_member department date_created year resource_type
                    institution degree discipline degree_granting_institution types
                    license language format identifier based_near access_right
                    rights_notes related_url video_embed bibliographic_citation
                    additional_rights_info
                    representative_id thumbnail_id rendering_ids files
                    visibility_during_embargo embargo_release_date visibility_after_embargo
                    visibility_during_lease lease_expiration_date visibility_after_lease
                    visibility ordered_member_ids source in_works_ids
                    member_of_collection_ids admin_set_id]

    self.terms -= %i[
      based_near
      date_created
    ]

    def primary_terms
      super - %i[video_embed] + %i[keyword] + %i[license]
    end
  end
end
