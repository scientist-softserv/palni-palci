# frozen_string_literal: true

class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Hydra::AccessControlsEnforcement
  include Hyrax::SearchFilters

  # PALNI-PALCI Seach builder extensions
  include SearchBuilder::AlphabeticalTitle
end
