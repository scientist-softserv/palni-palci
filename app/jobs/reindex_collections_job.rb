# frozen_string_literal: true

class ReindexCollectionsJob < ApplicationJob
  def perform(collection_id = nil)
    if collection_id.present?
      collection = Collection.find(collection_id)
      collection&.update_index
    else
      Collection.find_each do |collection|
        collection.try(:reindex_extent=, Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX)
        collection.update_index
      end
    end
  end
end
