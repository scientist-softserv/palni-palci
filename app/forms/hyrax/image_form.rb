# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImageForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Image
    include PdfFormBehavior

    self.terms = [:admin_note, :video_embed] + self.terms # rubocop:disable Style/RedundantSelf
    self.terms += %i[resource_type extent additional_information bibliographic_citation]
    self.required_fields = %i[title creator keyword rights_statement resource_type]

    def secondary_terms
      super + %i[video_embed]
    end
  end
end
