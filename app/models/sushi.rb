# frozen_string_literal:true

module Sushi
  class NotFoundError < StandardError
    class << self
      def no_records_within_date_range
        new('There are no results for the given date range.')
      end

      def invalid_item_id(item_id)
        new("The given parameter `item_id=#{item_id}` is invalid. Please provide a valid item_id, or none at all.")
      end
    end
  end

  ##
  # Raised when the parameter we are given does not match our expectations; e.g. we can't convert
  # the text value to a Date.
  class InvalidParameterValue < StandardError
    # rubocop:disable Metrics/LineLength
    class << self
      def invalid_platform(platform, account)
        new("The given parameter `platform=#{platform}` is not supported at this endpoint. Please use #{account.cname} instead. (Or do not pass the parameter at all, which will default to #{account.cname})}")
      end

      def invalid_access_method(access_method, acceptable_params)
        new("None of the given values in `access_method=#{access_method}` are supported at this time. Please use an acceptable value, (#{acceptable_params.join(', ')}) instead. (Or do not pass the parameter at all, which will default to the acceptable value(s))")
      end
    end
    # rubocop:enable Metrics/LineLength
  end

  class << self
    ##
    # @param value [String, #to_date]
    #
    # @return [Date]
    # @raise [Sushi::InvalidParameterValue] when we cannot coerce to a date.
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

    ##
    # The first day of the month of the earliest entry in {Hyrax::CounterMetric}, with some caveats.
    #
    # Namely if we only have one month of data, and that month happens to be the current month.
    #
    # @param current_date [Date] included as a dependency injection to ease testing.
    #
    # @return [Date] when we have data in the system
    # @return [NilCass] when we don't have data in the system OR we only have data for the current
    #         month.
    # @see {.last_month_available}
    #
    # @note Ultimately, the goal of these date ranges is for us to inform the consumer of the API
    #       about the complete months of data that we have.
    def first_month_available(current_date: Time.zone.today)
      return unless Hyrax::CounterMetric.any?

      # If, for some reason, we have only partial data for the earliest month, we'll assume that
      # we have "all that month's data.
      earliest_entry_beginning_of_month_date = Hyrax::CounterMetric.order('date ASC').first.date.beginning_of_month

      beginning_of_month = current_date.beginning_of_month

      # In this case, the only data we have is data in the current month and since the current month
      # isn't over we should not be reporting.
      return nil if earliest_entry_beginning_of_month_date == beginning_of_month

      earliest_entry_beginning_of_month_date
    end

    ##
    # The earlier of:
    #
    # - the last day of the prior month
    # - the last day of the month of the latest entry in {Hyrax::CounterMetric}
    #
    # @param current_date [Date] included as a dependency injection to ease testing.  An assumption
    #        is that the current_date will always be on or after the last {Hyrax::CounterMetric}
    #        entry's date.
    #
    # @return [Date] when we have data in the system
    # @return [NilCass] when we don't have data in the system
    #
    # @see {.first_month_available}
    #
    # @note Ultimately, the goal of these date ranges is for us to inform the consumer of the API
    #       about the complete months of data that we have.
    def last_month_available(current_date: Time.zone.today)
      return nil unless first_month_available(current_date: current_date)

      # We're assuming that we have whole months, so we'll nudge the latest date towards that
      # assumption.
      latest_entry_end_of_month_date = Hyrax::CounterMetric.order('date DESC').first.date.end_of_month

      # We want to avoid partial months, we look at the month prior to the current_date
      end_of_last_month = 1.month.ago(current_date).end_of_month

      return latest_entry_end_of_month_date if latest_entry_end_of_month_date < end_of_last_month

      end_of_last_month
    end
  end

  ##
  # This module accounts for date behavior that needs to be used across all reports.
  #
  # @see #coerce_dates
  module DateCoercion
    extend ActiveSupport::Concern
    included do
      attr_reader :begin_date
      attr_reader :end_date
    end

    ##
    # @param params [Hash, ActionController::Parameters]
    # @option params [String, NilClass] begin_date :: Either nil, YYYY-MM or YYYY-MM-DD format
    # @option params [String, NilClass] end_date :: Either nil, YYYY-MM or YYYY-MM-DD format
    def coerce_dates(params = {})
      # TODO: We should also be considering available dates as well.
      #
      # Because we're receiving user input that is likely strings, we need to do some coercion.
      @begin_date = Sushi.coerce_to_date(params.fetch(:begin_date)).beginning_of_month
      @end_date = Sushi.coerce_to_date(params.fetch(:end_date)).end_of_month
    end
  end

  ##
  # This module provides coercion of the :data_type parameter
  #
  # @see #coerce_data_types
  module DataTypeCoercion
    extend ActiveSupport::Concern
    included do
      attr_reader :data_types, :data_type_in_params
    end

    ##
    # @param params [Hash, ActionController::Parameters]
    # @option params [String, NilClass] data_type :: Pipe separated string of one or more data_types.
    def coerce_data_types(params = {})
      @data_type_in_params = params.key?(:data_type)
      @data_types = Array.wrap(params[:data_type]&.split('|')).map { |dt| dt.strip.downcase }
    end
  end

  module MetricTypeCoercion
    extend ActiveSupport::Concern
    included do
      attr_reader :metric_types, :metric_type_in_params
    end

    def coerce_metric_types(params = {}, allowed_types: ALLOWED_METRIC_TYPES)
      metric_types_from_params = Array.wrap(params[:metric_type]&.split('|'))

      @metric_type_in_params = metric_types_from_params.any? do |metric_type|
        normalized_metric_type = metric_type.downcase
        allowed_types.any? { |allowed_type| allowed_type.downcase == normalized_metric_type }
      end

      @metric_types = if metric_types_from_params.empty?
                        allowed_types
                      else
                        metric_types_from_params.map do |metric_type|
                          normalized_metric_type = metric_type.downcase
                          metric_type.titleize.tr(' ', '_') if allowed_types.any? { |allowed_type| allowed_type.downcase == normalized_metric_type }
                        end.compact
                      end
    end
  end

  ##
  # This module holds validations for the various query parameters that are available on each of the reports
  module QueryParameterValidation
    extend ActiveSupport::Concern
    included do
      attr_reader :access_methods, :access_method_in_params, :item_id, :item_id_in_params, :platform, :platform_in_params
    end

    ALLOWED_ACCESS_METHODS = ['regular'].freeze

    ##
    # @param params [Hash, ActionController::Parameters]
    def validate_access_method(params)
      return true unless params.key?(:access_method)
      allowed_access_methods_from_params = Array.wrap(params[:access_method].split('|')).map { |am| am.strip.downcase } & ALLOWED_ACCESS_METHODS

      raise Sushi::InvalidParameterValue.invalid_access_method(params[:access_method], ALLOWED_ACCESS_METHODS) unless allowed_access_methods_from_params.any?

      @access_methods = allowed_access_methods_from_params
      @access_method_in_params = true
    end

    ##
    # @param params [Hash, ActionController::Parameters]
    def validate_author(params)
      # TODO
      return true unless params.key?(:author)
      # raise Sushi::InvalidParameterValue.invalid_author(params[:author]) unless

      # @authors =
      @author_in_params = true
    end

    ##
    # @param params [Hash, ActionController::Parameters]
    def validate_item_id(params)
      return true unless params.key?(:item_id)
      raise Sushi::NotFoundError.invalid_item_id(params[:item_id]) unless Hyrax::CounterMetric.exists?(work_id: params[:item_id])

      @item_id = params[:item_id]
      @item_id_in_params = true
    end

    ##
    # @param params [Hash, ActionController::Parameters]
    def validate_platform(params, account)
      return true unless params.key?(:platform)
      raise Sushi::InvalidParameterValue.invalid_platform(params[:platform], account) unless params[:platform] == account.cname

      @platform = account.cname
      @platform_in_params = true
    end
  end

  # This param specifies the granularity of the usage data to include in the report.
  # Permissible values are Month (default) and Totals.
  # For Totals, each Item_Performance element represents the aggregated usage for the reporting period.
  # See https://cop5.projectcounter.org/en/5.1/03-specifications/03-counter-report-common-attributes-and-elements.html#report-filters-and-report-attributes for details
  module GranularityCoercion
    extend ActiveSupport::Concern
    included do
      attr_reader :granularity, :granularity_in_params
    end
    ALLOWED_GRANULARITY = ["Month", "Totals"].freeze

    def coerce_granularity(params = {})
      @granularity_in_params = ALLOWED_GRANULARITY.include?(params[:granularity].to_s.capitalize)
      @granularity = params.fetch(:granularity, "Month").capitalize
    end
  end
end
