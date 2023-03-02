# frozen_string_literal: true

# OVERRIDE BULKRAX 4.3.0
module Bulkrax
  module CsvEntryDecorator
    # NOTE: fixes issue where required keys with empty values were considered present
    def build_metadata
      raise StandardError, 'Record not found' if record.nil?
      keys_with_values = record.reject { |_, v| v.blank? }.keys
      unless importerexporter.parser.required_elements?(keys_without_numbers(keys_with_values))
        raise StandardError, "Missing required elements, missing element(s) are:"\
" #{importerexporter.parser.missing_elements(keys_without_numbers(keys_with_values)).join(', ')}"
      end

      self.parsed_metadata = {} # rubocop:disable Style/RedundantSelf
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
  end
end

Bulkrax::CsvEntry.prepend(Bulkrax::CsvEntryDecorator)
