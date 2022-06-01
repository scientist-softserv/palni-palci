# frozen_string_literal: true

# OVERRIDE BULKRAX 3.1.2 to include oer specific methods
module Bulkrax
  module CsvParserDecorator
    include OerCsvParser
  end
end

Bulkrax::CsvParser.prepend(Bulkrax::CsvParserDecorator)
