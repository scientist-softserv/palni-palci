# frozen_string_literal: true

# OVERRIDE Hyrax 3.6.0 to add custom sort fields while in the dashboard for works
# OVERRIDE Hyrax 3.5.0 to update collections_service method to remove all params

module Hyrax
  module My
    module WorksControllerClassDecorator
      def configure_facets
        configure_blacklight do |config|
          # clear facets copied from the CatalogController
          config.sort_fields.clear
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

    module WorksControllerDecorator
      # OVERRIDE FROM HYRAX: CAN REMOVE AT 4.0
      # https://github.com/samvera/hyrax/pull/5972
      def collections_service
        cloned = clone
        cloned.params = {}
        Hyrax::CollectionsService.new(cloned)
      end
    end
  end
end

Hyrax::My::WorksController.singleton_class.send(:prepend, Hyrax::My::WorksControllerClassDecorator)
Hyrax::My::WorksController.configure_facets

Hyrax::My::WorksController.prepend(Hyrax::My::WorksControllerDecorator)
