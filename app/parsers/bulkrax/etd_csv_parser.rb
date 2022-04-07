# frozen_string_literal: true

module Bulkrax
  class EtdCsvParser < CsvParser
    def entry_class
      Bulkrax::EtdCsvEntry
    end
    alias work_entry_class entry_class
  end
end
