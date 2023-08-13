# frozen_string_literal: true

module Bulkrax
  module HasLocalProcessing
    # This method is called during build_metadata
    # add any special processing here, for example to reset a metadata property
    # to add a custom property from outside of the import data
    def add_local
      parsed_metadata['year'] = parse_year(parsed_metadata['year']) if parsed_metadata['year']
      parsed_metadata['format'] = parse_format(parsed_metadata['format']) if parsed_metadata['format']
    end

    def form_class
      return false unless parsed_metadata['model'].present?
      @form_class ||= "Hyrax::#{parsed_metadata['model']}Form".constantize
    end

    def validate?(attribute)
      form_class.required_fields.include?(attribute)
    end

    def parse_year(src)
      src = src.strip.chomp
      return src unless validate?(:year)
      valid = src.match?(/^(19|20)\d{2}$/)
      error_msg = %("#{src}" is not a 4 digit year.)
      valid ? src : (raise ::StandardError, error_msg)
    end

    def parse_format(src)
      src.map do |format|
        # will return nil if it doesn't match with any format label
        label = Hyrax::FormatService.label_from_alt(format)
        if validate?(:format)
          valid = label.present?
          error_msg = %("#{format}" is not a valid type of format.)
          raise(::StandardError, error_msg) unless valid
        end
        label
      end
    end
  end
end
