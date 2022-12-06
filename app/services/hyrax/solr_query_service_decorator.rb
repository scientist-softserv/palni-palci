# OVERRIDE: Hyrax 3.4.1 changes GET request to POST to allow for larger query size

# frozen_string_literal: true

module Hyrax
  module SolrQueryServiceDecorator
    def get
      solr_service.post(build)
    end
  end
end

Hyrax::SolrQueryService.prepend(Hyrax::SolrQueryServiceDecorator)
