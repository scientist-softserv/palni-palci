# frozen_string_literal: true

# OVERRIDE BULKRAX 4.3.0
module Bulkrax
  module CsvEntryDecorator
    # NOTE: fixes issue where required keys with empty values were considered present
    # remove if bulkrax has been upgraded to version 5.2 or higher
    def build_metadata
      validate_record

      self.parsed_metadata = {}
      add_identifier
      add_ingested_metadata
      add_collections
      add_visibility
      add_metadata_for_model
      add_rights_statement
      sanitize_controlled_uri_values!
      add_local

      self.parsed_metadata # rubocop:disable Style/RedundantSelf
    end

    def validate_record
      raise StandardError, 'Record not found' if record.nil?
      unless importerexporter.parser.required_elements?(record)
        raise StandardError, "Missing required elements, missing element(s) are: "\
"#{importerexporter.parser.missing_elements(record).join(', ')}"
      end
    end
  end
end

Bulkrax::CsvEntry.prepend(Bulkrax::CsvEntryDecorator)
