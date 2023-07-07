# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated form for Etd
  class EtdForm < Hyrax::Forms::WorkForm
    self.model_class = ::Etd
    self.required_fields += %i[
      year
      subject
      resource_type
      institution
      degree
      discipline
      degree_granting_institution
      types
    ]
    self.terms += %i[
      year
      video_embed
      institution
      resource_type
      additional_rights_info
      bibliographic_citation
      format
      degree
      discipline
      degree_granting_institution
      advisor
      committee_member
      department
      types
    ]
    self.terms -= %i[
      based_near
      date_created
    ]

    def primary_terms
      super + %i[video_embed] - %i[license]
    end
  end
end
