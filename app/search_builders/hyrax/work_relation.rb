# frozen_string_literal: true

# Override Hyrax 2.8 allow getting at raw search results, for workflow pagination
module Hyrax
  class WorkRelation < AbstractTypeRelation
    def allowable_types
      Hyrax.config.curation_concerns
    end

    def search_with_conditions(conditions, opts = {})
      # set default sort to created date ascending
      opts[:sort] = @klass.default_sort_params unless opts.include?(:sort)
      if opts.delete(:paginate)
        opts.delete(:method)
        @search_result = ActiveFedora::SolrService.post(create_query(conditions), opts)
        @search_result['response']['docs'].map do |doc|
          ActiveFedora::SolrHit.new(doc)
        end
      else
        ActiveFedora::SolrService.query(create_query(conditions), opts)
      end
    end

    attr_reader :search_result
  end
end
