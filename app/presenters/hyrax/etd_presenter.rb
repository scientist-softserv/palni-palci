# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  class EtdPresenter < Hyku::WorkShowPresenter
    delegate :alternative_title,
             :additional_information,
             :bibliographic_citation,
             to: :solr_document
  end
end
