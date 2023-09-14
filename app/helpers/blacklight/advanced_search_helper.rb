# frozen_string_literal: true

module Blacklight
  module AdvancedSearchHelper
    def primary_search_fields_for(fields)
      fields.each_with_index.partition { |_, idx| idx < 6 }.first.map(&:first)
    end

    def secondary_search_fields_for(fields)
      fields.each_with_index.partition { |_, idx| idx < 6 }.last.map(&:first)
    end

    def local_authority?(key)
      local_qa_names = Qa::Authorities::Local.names
      local_qa_names.include?(key.pluralize) || local_qa_names.include?(key)
    end

    def options_for_qa_select(key)
        service = fetch_service_for(key)
        service.try(:select_all_options) || service.try(:select_options) || service.new.select_all_options
    end

    def fetch_service_for(key)
      "Hyrax::#{key.camelize}Service".safe_constantize || "Hyrax::#{key.pluralize.camelize}Service".safe_constantize
    end
  end
end
