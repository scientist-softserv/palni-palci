# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated form for Etd
  class EtdForm < Hyrax::Forms::WorkForm
    self.model_class = ::Etd
    self.required_fields += %i[
      title
      creator
      rights_statement
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
      resource_type
      bibliographic_citation
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
  end
end
