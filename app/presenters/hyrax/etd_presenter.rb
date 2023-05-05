# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  class EtdPresenter < Hyku::WorkShowPresenter
    delegate :bibliographic_citation,
             to: :solr_document
  end
end
