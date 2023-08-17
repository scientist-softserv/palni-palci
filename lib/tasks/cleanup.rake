# frozen_string_literal: true

namespace :cleanup do
  desc 'make sure all works have source_identifiers'
  task source_identifier: :environment do
    Account.find_each do |account|
      switch!(account)
      Hyrax.config.registered_curation_concern_types.each do |work_type|
        work_type.constantize.find_each do |work|
          next if work.source_identifier.present?
          work.source_identifier = SecureRandom.uuid
          work.save
        end
      end
    end
  end
end
