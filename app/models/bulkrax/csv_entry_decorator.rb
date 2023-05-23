module Bulkrax
  # Override Bulkrax v5.2.1
  module CsvEntryDecorator
    def export_work_url
      work_type = self.parsed_metadata['model'].underscore.pluralize
      if work_type === 'collections'
        work_path = "https://#{Site.instance.account.cname}/#{work_type}/#{self.parsed_metadata['id']}"
      else
        work_path = "https://#{Site.instance.account.cname}/concern/#{work_type}/#{self.parsed_metadata['id']}"
      end
      return work_path
    end

    def build_export_metadata
      self.parsed_metadata = {}
      build_system_metadata
      # OVERRIDE here to add the work_url to the export
      self.parsed_metadata['work_url'] = export_work_url
      build_files_metadata if defined?(Collection) && !hyrax_record.is_a?(Collection)
      build_relationship_metadata
      build_mapping_metadata
      self.save!

      self.parsed_metadata
    end
  end
end
Bulkrax::CsvEntry.prepend(Bulkrax::CsvEntryDecorator)