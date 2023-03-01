# frozen_string_literal: true

# OVERRIDE BULKRAX 3.1.2 to include oer specific methods
module Bulkrax
  module CsvParserDecorator
    include OerCsvParser

    # @return [Array<String>]
    def required_elements
      if Bulkrax.fill_in_blank_source_identifiers
        %w[title resource_type]
      else
        ['title', 'resource_type', source_identifier]
      end
    end
  end
end

Bulkrax::CsvParser.prepend(Bulkrax::CsvParserDecorator)
