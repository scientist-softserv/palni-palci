# frozen_string_literal: true

# Generated via
#  `rails generate curation_concerns:work GenericWork`
module Hyrax
  class GenericWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions
    self.terms.prepend(:admin_note).uniq!
    self.terms += %i[resource_type additional_information bibliographic_citation]
    self.terms -=%i[based_near]
    self.required_fields = %i[title creator keyword rights_statement]
  end
end
