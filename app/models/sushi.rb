# frozen_string_literal:true

module Sushi
  ##
  # Raised when the parameter we are given does not match our expectations; e.g. we can't convert
  # the text value to a Date.
  class InvalidParameterValue < StandardError
  end

  class << self
    def coerce_to_date(value)
      value.to_date
    rescue StandardError
      begin
        # We can't parse the original date, so lets attempt to coerce a "YYYY-MM" string (year-month).
        # If it fails, we'll raise an exception on garbage input.
        year, month, = value.split('-')

        # We want to set the date to the 1st of the month.
        Date.new(year.to_i, month.to_i, 1)
      rescue StandardError
        raise Sushi::InvalidParameterValue, "Unable to convert \"#{value}\" to a date."
      end
    end

    def first_month_available
      return unless Hyrax::CounterMetric.any?

      Hyrax::CounterMetric.order('date ASC').first.date.strftime('%Y-%m')
    end

    def last_month_available
      return unless Hyrax::CounterMetric.any?

      Hyrax::CounterMetric.order('date DESC').first.date.strftime('%Y-%m')
    end
  end

  # this module accounts for date behavior that needs to be used across all reports.
  module DateCoercion
    extend ActiveSupport::Concern
    included do
      attr_reader :begin_date
      attr_reader :end_date
    end

    def coerce_dates(params = {})
      # Because we're receiving user input that is likely strings, we need to do some coercion.
      @begin_date = Sushi.coerce_to_date(params.fetch(:begin_date)).beginning_of_month
      @end_date = Sushi.coerce_to_date(params.fetch(:end_date)).end_of_month
    end
  end

  module DataTypeCoercion
    extend ActiveSupport::Concern
    included do
      attr_reader :data_types, :data_type_in_params
    end

    def coerce_data_types(params = {})
      @data_type_in_params = params.key?(:data_type)
      @data_types = Array.wrap(params[:data_type]&.split('|')).map(&:downcase)
    end
  end

  module MetricTypeCoercion
    extend ActiveSupport::Concern
    included do
      attr_reader :metric_types, :metric_type_in_params
    end
    ALLOWED_METRIC_TYPES = [
      "Total_Item_Investigations",
      "Total_Item_Requests",
      "Unique_Item_Investigations",
      "Unique_Item_Requests",
      "Unique_Title_Investigations",
      "Unique_Title_Requests"
    ]

    def coerce_metric_types(params = {})
      metric_types_from_params = Array.wrap(params[:metric_type]&.split('|'))

      @metric_type_in_params = metric_types_from_params.any? do |metric_type|
        normalized_metric_type = metric_type.downcase
        ALLOWED_METRIC_TYPES.any? { |allowed_type| allowed_type.downcase == normalized_metric_type }
      end

      @metric_types = if metric_types_from_params.empty?
        ALLOWED_METRIC_TYPES
      else
        metric_types_from_params.map do |metric_type|
          normalized_metric_type = metric_type.downcase
          if ALLOWED_METRIC_TYPES.any? { |allowed_type| allowed_type.downcase == normalized_metric_type }
            metric_type.titleize.gsub(' ', '_')
          end
        end.compact
      end
    end
  end
end
