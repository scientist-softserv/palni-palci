# frozen_string_literal:true

# counter compliant format for the Platform Usage Report is found here: https://countermetrics.stoplight.io/docs/counter-sushi-api/82bd896d1dd60-pr-p1-platform-usage
#
# dates will be filtered by including the begin_date, and excluding the end_date
# e.g. if you want to full month, begin_date should be the first day of that month, and end_date should be the first day of the following month.
module Sushi
  class PlatformUsageReport
    attr_reader :created, :account
    include Sushi::DateCoercion
    include Sushi::DataTypeCoercion
    include Sushi::MetricTypeCoercion

    def initialize(params = {}, created: Time.zone.now, account:)
      coerce_dates(params)
      coerce_data_types(params)
      coerce_metric_types(params, allowed_types: ALLOWED_METRIC_TYPES)

      @created = created
      @account = account
    end

    # the platform usage report only contains requests. see https://countermetrics.stoplight.io/docs/counter-sushi-api/mgu8ibcbgrwe0-pr-p1-performance-other for details
    ALLOWED_METRIC_TYPES = ["Unique_Item_Requests", "Total_Item_Requests"].freeze

    def as_json(_options = {})
      report_hash = {
        "Report_Header" => {
          "Release" => "5.1",
          "Report_ID" => "PR_P1",
          "Report_Name" => "Platform Usage",
          "Created" => created.rfc3339, # "2023-02-15T09:11:12Z"
          "Created_By" => account.institution_name,
          "Institution_ID" => account.institution_id_data,
          "Institution_Name" => account.institution_name,
          "Registry_Record" => "",
          "Report_Filters" => {
            "Begin_Date" => begin_date.iso8601,
            "End_Date" => end_date.iso8601,
            "Access_Method" => [
              "Regular"
            ]
          }
        },
        "Report_Items" => {
          "Platform" => account.cname,
          "Attribute_Performance" => attribute_performance_for_resource_types + attribute_performance_for_platform
        }
      }
      report_hash["Report_Header"]["Report_Filters"]["Data_Type"] = data_types if data_type_in_params
      report_hash["Report_Header"]["Report_Filters"]["Metric_Type"] = metric_types if metric_type_in_params
      report_hash
    end
    alias to_hash as_json

    def attribute_performance_for_resource_types
      data_for_resource_types.group_by(&:resource_type).map do |resource_type, records|
        { "Data_Type" => resource_type || "",
          "Access_Method" => "Regular",
          "Performance" => performance(records) }
      end
    end

    def performance(records)
      metric_types.each_with_object({}) do |metric_type, hash|
        hash[metric_type] = records.each_with_object({}) do |record, inner_hash|
          inner_hash[record.year_month.strftime("%Y-%m")] = record[metric_type.downcase.to_s]
          inner_hash
        end
      end
    end

    def attribute_performance_for_platform
      [{
        "Data_Type" => "Platform",
        "Access_Method" => "Regular",
        "Performance" => {
          "Searches_Platform" => data_for_platform.each_with_object({}) do |record, hash|
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
                         "SUM(total_item_requests) as total_item_requests",
                         "COUNT(DISTINCT CASE WHEN total_item_investigations IS NOT NULL THEN CONCAT(work_id, '_', date::text) END) as unique_item_investigations",
                         "COUNT(DISTINCT CASE WHEN total_item_requests IS NOT NULL THEN CONCAT(work_id, '_', date::text) END) as unique_item_requests")
                 .where("date >= ? AND date <= ?", begin_date, end_date)
                 .order(:resource_type, "year_month")
                 .group(:resource_type, "date_trunc('month', date)")

      return relation if data_types.blank?

      relation.where("LOWER(resource_type) IN (?)", data_types)
    end

    def data_for_platform
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
