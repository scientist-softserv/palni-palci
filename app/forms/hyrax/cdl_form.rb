# Generated via
#  `rails generate hyrax:work Cdl`
module Hyrax
  # Generated form for Cdl
  class CdlForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Cdl
    include HydraEditor::Form::Permissions
    self.terms.prepend(:admin_note).uniq! # rubocop:disable Style/RedundantSelf
    self.terms += %i[resource_type additional_information bibliographic_citation contributing_library library_catalog_identifier chronology_note]
    self.terms -= %i[based_near]
    self.required_fields = %i[title creator keyword rights_statement resource_type]
  end
end
