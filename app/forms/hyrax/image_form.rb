# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImageForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Image
    self.terms += %i[rights_notes resource_type extent]
  end
end
