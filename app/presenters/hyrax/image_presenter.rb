# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImagePresenter < Hyku::WorkShowPresenter
    # We do not use this generated ImagePresenter. Instead we use the
    # WorkShowPresenter
    delegate :additional_rights_info,
             :bibliographic_citation,
             :institution,
             :types,
             :format,
             :location,
             to: :solr_document
  end
end
