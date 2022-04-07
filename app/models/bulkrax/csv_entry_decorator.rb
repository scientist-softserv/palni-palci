# frozen_string_literal: true

# OVERRIDE BULKRAX 3.0.0.beta3
module Bulkrax
  module CsvEntryDecorator
    # rubocop:disable Metrics/LineLength
    def build_metadata
      raise StandardError, 'Record not found' if record.nil?
      raise StandardError, "Missing required elements, missing element(s) are: #{importerexporter.parser.missing_elements(keys_without_numbers(record.keys)).join(', ')}" unless importerexporter.parser.required_elements?(keys_without_numbers(record.keys))

      self.parsed_metadata = {}
      add_identifier
      add_ingested_metadata
      # OVERRIDE: add collections again
      # TODO(shanalmoore): remove this file when adding collections from csv's is updated to align with current 3.0 implementation
      add_collections
      add_visibility
      add_metadata_for_model
      add_rights_statement
      add_local

      self.parsed_metadata # rubocop:disable Style/RedundantSelf
    end

    def possible_collection_ids
      return @possible_collection_ids if @possible_collection_ids.present?

      parent_field_mapping = self.class.parent_field(parser)
      return [] unless parent_field_mapping.present? && record[parent_field_mapping].present?

      identifiers = []
      split_references = record[parent_field_mapping].split(/\s*[;|]\s*/)
      split_references.each do |c_reference|
        # OVERRIDE: better collection determination
        matching_collection_entries = importerexporter.entries.select { |e| e.raw_metadata['source_identifier'] == c_reference && e.is_a?(CsvCollectionEntry) }
        raise ::StandardError, 'Only expected to find one matching entry' if matching_collection_entries.count > 1
        identifiers << matching_collection_entries.first&.identifier
      end

      @possible_collection_ids = identifiers.compact.presence || []
    end
    # rubocop:enable Metrics/LineLength
  end
end

Bulkrax::CsvEntry.prepend(Bulkrax::CsvEntryDecorator)
