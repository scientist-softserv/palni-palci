# frozen_string_literal: true

# OVERRIDE Blacklight v6.25.0 to add custom sort fields while in the dashboard for both collections and works

module Blacklight
  module ConfigurationHelperBehavior
    def active_sort_fields
      config = if dashboard_controller_and_index_action?
                 dashboard_config
               else
                 blacklight_config
               end

      config.sort_fields.select { |_sort_key, field_config| should_render_field?(field_config) }
    end

    def dashboard_controller_and_index_action?
      (params[:controller].include?('hyrax/my/collections') || params[:controller].include?('hyrax/dashboard/collections')) && action_name == 'index'
    end

    def dashboard_config
      @dashboard_config ||= Blacklight::Configuration.new do |config|
        # Collections don't seem to have a date_uploaded_dtsi nor date_modified_dtsi
        # we can at least use the system_modified_dtsi instead of date_modified_dtsi
        # but we will omit date_uploaded_dtsi
        config.add_sort_field "system_modified_dtsi desc", label: "date modified \u25BC"
        config.add_sort_field "system_modified_dtsi asc", label: "date modified \u25B2"
        config.add_sort_field "system_create_dtsi desc", label: "date created \u25BC"
        config.add_sort_field "system_create_dtsi asc", label: "date created \u25B2"
        config.add_sort_field "depositor_ssi asc, title_ssi asc", label: "depositor (A-Z)"
        config.add_sort_field "depositor_ssi desc, title_ssi desc", label: "depositor (Z-A)"
        config.add_sort_field "creator_ssi asc, title_ssi asc", label: "creator (A-Z)"
        config.add_sort_field "creator_ssi desc, title_ssi desc", label: "creator (Z-A)"
      end
    end

    def sort_field_label(key)
      field_config = if dashboard_controller_and_index_action?
                       dashboard_config.sort_fields[key]
                     else
                       blacklight_config.sort_fields[key]
                     end
      field_config ||= Blacklight::Configuration::NullField.new(key: key)

      field_label(
        :"blacklight.search.fields.sort.#{key}",
        (field_config&.label),
        key.to_s.humanize
      )
    end
  end
end
