# frozen_string_literal: true

module ActiveFedora
  module BaseDecorator
    def multi_valued_properties_for_ordering
      properties.collect do |prop_name, node_config|
        next if %w[head tail].include?(prop_name)

        prop_name.to_sym if node_config.instance_variable_get(:@opts)&.dig(:multiple)
      end.compact
    end
  end
end

ActiveFedora::Base.extend(ActiveFedora::BaseDecorator)
