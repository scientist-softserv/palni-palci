# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work GenericWork`
module Hyrax
  class GenericWorkPresenter < Hyku::WorkShowPresenter
    # delegate fields from Hyrax::GenricWorks::Metadata to solr_document
    delegate :institution,
             :format,
             :types,
             to: :solr_document
  end
end
