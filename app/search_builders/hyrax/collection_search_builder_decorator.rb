# frozen_string_literal: true

module Hyrax
  module CollectionSearchBuilderDecorator
    # OVERRIDE Hyrax 3.6.0 to use title_ssi instead of title_si (hyrax's default value)
    def sort_field
      DEFAULT_SORT_FIELD
    end

    DEFAULT_SORT_FIELD = 'title_ssi'
  end
end

Hyrax::CollectionSearchBuilder.prepend Hyrax::CollectionSearchBuilderDecorator
