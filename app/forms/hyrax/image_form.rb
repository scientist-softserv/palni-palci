# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImageForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Image
    include PdfFormBehavior
    self.terms += %i[resource_type
                     extent
                     additional_rights_info
                     bibliographic_citation
                     institution
                     types
                     format
                     video_embed
                     location]
    self.terms = %i[title alternative_title creator date_created contributor
                    description abstract subject keyword location extent rights_statement
                    publisher resource_type institution types license language format
                    identifier based_near access_right rights_notes related_url
                    video_embed bibliographic_citation additional_rights_info
                    representative_id thumbnail_id rendering_ids files
                    visibility_during_embargo embargo_release_date
                    visibility_after_embargo
                    visibility_during_lease lease_expiration_date visibility_after_lease
                    visibility ordered_member_ids source in_works_ids
                    member_of_collection_ids admin_set_id]

    self.required_fields += %i[institution
                               resource_type
                               types]
    self.terms -= %i[based_near]
    def primary_terms
      super - %i[video_embed] + %i[license]
    end
  end
end
