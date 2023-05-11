# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
      parsed_metadata['year'] = parse_year(parsed_metadata['year']) if parsed_metadata['year']
  end

  def parse_year(src)
    src = src.strip.chomp
    valid = src.match?(/^(19|20)\d{2}$/)
    error_msg = %("#{src}" is not a 4 digit year.)
    valid ? src : (raise ::StandardError, error_msg)
  end
end