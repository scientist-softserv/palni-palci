# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImageForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Image
    self.terms += %i[resource_type extent alternative_title additional_information rights_notes bibliographic_citation abstract]
    self.terms -=%i[based_near]
  end
end
