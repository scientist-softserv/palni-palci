# frozen_string_literal: true

class ReindexWorksJob < ApplicationJob
  def perform(input = nil)
    if input.present?
      reindex_things(Array.wrap(input))
    else
      Hyrax.config.registered_curation_concern_types.each do |work_type|
        work_type.constantize.find_each(&:update_index)
      end
    end
  end

  def reindex_things(things)
    things.each do |thing|
      if thing.respond_to?(:update_index)
        thing.update_index
      else
        begin
          ActiveFedora::Base.find(thing).update_index
        rescue ActiveFedora::ObjectNotFoundError
          Rails.logger.info("ReindexWorksJob: #{thing} not found")
        end
      end
    end
  end
end
