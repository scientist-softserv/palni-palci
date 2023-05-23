# frozen_string_literal: true

module Bulkrax
  # Override Bulkrax v5.2.1
  module CsvEntryDecorator
    def export_work_url
      work_type = parsed_metadata['model'].underscore.pluralize
      work_path = if work_type == 'collections'
                    "https://#{Site.instance.account.cname}/#{work_type}/#{parsed_metadata['id']}"
                  else
                    "https://#{Site.instance.account.cname}/concern/#{work_type}/#{parsed_metadata['id']}"
                  end
      work_path
    end

    def build_export_metadata
      self.parsed_metadata = {}
      build_system_metadata
      # OVERRIDE here to add the work_url to the export
      parsed_metadata['work_url'] = export_work_url
      build_files_metadata if defined?(Collection) && !hyrax_record.is_a?(Collection)
      build_relationship_metadata
      build_mapping_metadata
      save!

      parsed_metadata
    end
  end
end
Bulkrax::CsvEntry.prepend(Bulkrax::CsvEntryDecorator)
