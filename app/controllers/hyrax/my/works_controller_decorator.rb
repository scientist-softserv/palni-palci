# frozen_string_literal: true

module Hyrax
  module My
    module WorksControllerDecorator
      def configure_facets
        configure_blacklight do |config|
          config.sort_fields.each_key do |key|
            config.sort_fields.delete(key)
          end

          config.add_sort_field "date_uploaded_dtsi desc", label: "date uploaded \u25BC"
          config.add_sort_field "date_uploaded_dtsi asc", label: "date uploaded \u25B2"
          config.add_sort_field "date_modified_dtsi desc", label: "date modified \u25BC"
          config.add_sort_field "date_modified_dtsi asc", label: "date modified \u25B2"
          config.add_sort_field "system_create_dtsi desc", label: "date created \u25BC"
          config.add_sort_field "system_create_dtsi asc", label: "date created \u25B2"
          config.add_sort_field "depositor_ssi asc, title_ssi asc", label: "depositor (A-Z)"
          config.add_sort_field "depositor_ssi desc, title_ssi desc", label: "depositor (Z-A)"
          config.add_sort_field "creator_ssi asc, title_ssi asc", label: "creator (A-Z)"
          config.add_sort_field "creator_ssi desc, title_ssi desc", label: "creator (Z-A)"
        end
      end
    end
  end
end

Hyrax::My::WorksController.singleton_class.send(:prepend, Hyrax::My::WorksControllerDecorator)
Hyrax::My::WorksController.configure_facets
