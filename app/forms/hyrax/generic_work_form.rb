# frozen_string_literal: true

# Generated via
#  `rails generate curation_concerns:work GenericWork`
module Hyrax
  class GenericWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions
    include PdfFormBehavior
    self.terms += %i[
      resource_type
      format
      institution
      bibliographic_citation
      video_embed
      types
      additional_rights_info
    ]

    self.terms = %i[title alternative_title creator contributor description abstract
                    keyword subject rights_statement publisher date_created
                    resource_type institution types license language format
                    identifier based_near access_right rights_notes related_url
                    video_embed bibliographic_citation additional_rights_info
                    representative_id thumbnail_id rendering_ids files
                    visibility_during_embargo embargo_release_date
                    visibility_after_embargo
                    visibility_during_lease lease_expiration_date visibility_after_lease
                    visibility ordered_member_ids source in_works_ids
                    member_of_collection_ids admin_set_id]

    self.required_fields += %i[
      title
      creator
      rights_statement
      date_created
      resource_type
      institution
      types
    ]

    self.terms -= %i[
      based_near
    ]

    def primary_terms
      super - %i[video_embed] + %i[license]
    end
  end
end
