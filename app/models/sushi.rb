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
      attr_reader :data_types
    end

    def coerce_data_types(params = {})
      @data_types = Array.wrap(params[:data_type]&.split('|')).map(&:downcase)
    end
  end

  # this module accounts for data manipulation that needs to happen across all reports.
  module AttributePerformance
    extend ActiveSupport::Concern
    included do
      attr_reader :begin_date
      attr_reader :end_date
    end

    def attribute_performance_for_resource_types
      data_for_resource_types.group_by(&:resource_type).map do |resource_type, records|
        { "Data_Type" => resource_type || "",
          "Access_Method" => "Regular",
          "Performance" => {
            "Total_Item_Investigations" =>
            records.each_with_object({}) do |record, hash|
              hash[record.year_month.strftime("%Y-%m")] = record.total_item_investigations
              hash
            end,
            "Total_Item_Requests" =>
            records.each_with_object({}) do |record, hash|
              hash[record.year_month.strftime("%Y-%m")] = record.total_item_requests
              hash
            end
          } }
      end
    end

    def attribute_performance_for(resource_type:)
      [{
        "Data_Type" => resource_type,
        "Access_Method" => "Regular",
        "Performance" => {
          "Searches_#{resource_type}" => data_for_resource.each_with_object({}) do |record, hash|
            hash[record.year_month.strftime("%Y-%m")] = record.total_item_investigations
            hash
          end
        }
      }]
    end

    ##
    # @note the `date_trunc` SQL function is specific to Postgresql.  It will take the date/time field
    #       value and return a date/time object that is at the exact start of the date specificity.
    #
    #       For example, if we had "2023-01-03T13:14" and asked for the date_trunc of month, the
    #       query result value would be "2023-01-01T00:00" (e.g. the first moment of the first of the
    #       month).
    def data_for_resource_types
      # We're capturing this relation/query because in some cases, we need to chain another where
      # clause onto the relation.
      relation = Hyrax::CounterMetric
                 .select(:resource_type,
                         "date_trunc('month', date) AS year_month",
                         "SUM(total_item_investigations) as total_item_investigations",
                         "SUM(total_item_requests) as total_item_requests")
                 .where("date >= ? AND date <= ?", begin_date, end_date)
                 .order(:resource_type, "year_month")
                 .group(:resource_type, "date_trunc('month', date)")

      return relation if data_types.blank?

      relation.where("LOWER(resource_type) IN (?)", data_types)
    end

    def data_for_resource
      Hyrax::CounterMetric
        .select("date_trunc('month', date) AS year_month",
                "SUM(total_item_investigations) as total_item_investigations",
                "SUM(total_item_requests) as total_item_requests")
        .where("date >= ? AND date <= ?", begin_date, end_date)
        .order("year_month")
        .group("date_trunc('month', date)")
    end
  end
end
