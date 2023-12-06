# Generated via
#  `rails generate hyrax:work Cdl`
module Hyrax
  # Generated form for Cdl
  class CdlForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Cdl
    include HydraEditor::Form::Permissions
    include PdfFormBehavior
    # List these terms first after the "Additional fields" divider
    self.terms = %i[contributing_library library_catalog_identifier admin_note video_embed] + self.terms # rubocop:disable Style/RedundantSelf
    self.terms += %i[resource_type additional_information bibliographic_citation chronology_note]
    self.terms -= %i[based_near]
    self.required_fields = %i[title creator keyword rights_statement resource_type]

    def secondary_terms
      super + %i[video_embed]
    end
  end
end
