# frozen_string_literal: true

class ReindexCollectionsJob < ApplicationJob
  def perform(collection_id = nil)
    if collection_id.present?
      update_collection_index(Collection.find(collection_id))
    else
      Collection.find_each { |collection| update_collection_index(collection) }
    end
  end

  private

    def update_collection_index(collection)
      collection.try(:reindex_extent=, Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX)
      collection&.update_index
    end
end
