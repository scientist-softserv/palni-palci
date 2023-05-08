# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated form for Etd
  class EtdForm < Hyrax::Forms::WorkForm
    self.model_class = ::Etd
    self.required_fields += %i[
      date_created
      subject
      resource_type
      institution
      degree
      level
      discipline
      degree_granting_institution
    ]
    self.terms += %i[
      video_embed
      institution
      # bibliographic_citation
      format
      degree
      level
      discipline
      degree_granting_institution
      advisor
      committee_member
      department
    ]
    self.terms -= %i[
      based_near
    ]

    def primary_terms
      super + %i[video_embed] - %i[license]
    end
  end
end
