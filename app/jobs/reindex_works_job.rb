# frozen_string_literal: true

class ReindexWorksJob < ApplicationJob
  def perform(work = nil)
    if work.present?
      update_work_index(work)
    else
      Hyrax.config.registered_curation_concern_types.each do |work_type|
        work_type.constantize.find_each{ |work| update_work_index(work) }
      end
    end
  end

  private

  def update_work_index(work)
    work.try(:reindex_extent=, Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX)
    work&.update_index
  end
end