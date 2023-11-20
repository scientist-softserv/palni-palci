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
                     video_embed]
    self.required_fields += %i[abstract
                               date_created
                               resource_type
                               types]
    self.terms -= %i[based_near]
  end
end
