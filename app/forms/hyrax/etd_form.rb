# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated form for Etd
  class EtdForm < Hyrax::Forms::WorkForm
    self.model_class = ::Etd
    self.terms += [
      :resource_type,
      :bibliographic_citation
    ]
    self.terms -= %i[
      based_near
    ]
  end
end
