# frozen_string_literal: true

# Generated via
#  `rails generate curation_concerns:work GenericWork`
module Hyrax
  class GenericWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions
    self.terms += %i[
      resource_type
      format
      institution
      bibliographic_citation
      video_embed
      types
      additional_rights_info
    ]

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
