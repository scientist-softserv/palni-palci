# frozen_string_literal: true

namespace :hyku do
  desc 'Update all collections and works with inactive licenses to their active counterpart'
  task update_licenses: :environment do
    Collection.find_each do |collection|
      next if collection.license.blank?
      next unless collection.license.first.include?('3.0')

      collection.license = [collection.license.first.sub('3.0', '4.0')]
      collection.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
      collection.save!
    end

    Hyrax.config.curation_concerns.each do |work_type|
      work_type.find_each do |work|
        next if work.license.blank?
        next unless work.license.first.include?('3.0')

        work.license = [work.license.first.sub('3.0', '4.0')]
        work.save!
      end
    end
  end
end
