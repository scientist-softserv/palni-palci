# frozen_string_literal:true

# counter compliant format for the PlatformReport is found here: https://countermetrics.stoplight.io/docs/counter-sushi-api/e98e9f5cab5ed-pr-platform-report#Query-Parameters
#
# dates will be filtered by including the begin_date, and excluding the end_date
# e.g. if you want to full month, begin_date should be the first day of that month, and end_date should be the first day of the following month.
module Sushi
  class PlatformUsageReport
    attr_reader :created, :account
    include Sushi::DateCoercion
    include Sushi::DataTypeCoercion

    def initialize(params = {}, created: Time.zone.now, account:)
      coerce_dates(params)
      coerce_data_types(params)

      @created = created
      @account = account
    end

    def to_hash
      {
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
            "Metric_Type" => [
              "Searches_Platform",
              "Total_Item_Requests",
              "Unique_Item_Requests",
              "Unique_Title_Requests"
            ],
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
                         "SUM(total_item_requests) as total_item_requests")
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
