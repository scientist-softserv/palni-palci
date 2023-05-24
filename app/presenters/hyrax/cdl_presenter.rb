# Generated via
#  `rails generate hyrax:work Cdl`
module Hyrax
  class CdlPresenter < Hyku::WorkShowPresenter
    delegate :abstract, to: :solr_document
  end
end
