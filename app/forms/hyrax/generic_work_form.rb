# frozen_string_literal: true

# Generated via
#  `rails generate curation_concerns:work GenericWork`
module Hyrax
  class GenericWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions
    self.terms += %i[resource_type alternative_title additional_information rights_notes bibliographic_citation abstract]
    self.terms -=%i[based_near]
  end
end
