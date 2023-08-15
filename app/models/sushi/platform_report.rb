# frozen_string_literal:true

# counter compliant format for the PlatformReport is found here: https://countermetrics.stoplight.io/docs/counter-sushi-api/e98e9f5cab5ed-pr-platform-report
#
# dates will be filtered where both begin & end dates are inclusive.
# any provided begin_date will be moved to the beginning of the month
# any provided end_date will be moved to the end of the month
module Sushi
  class PlatformReport
    attr_reader :created, :account, :attributes_to_show, :data_types
    include Sushi::DateCoercion
    include Sushi::DataTypeCoercion
    ALLOWED_REPORT_ATTRIBUTES_TO_SHOW = [
      "Access_Method",
      # These are all the counter compliant query attributes, they are not currently supported in this implementation.
      # "Institution_Name",
      # "Customer_ID",
      # "Country_Name",
      # "Country_Code",
      # "Subdivision_Name",
      # "Subdivision_Code",
      # "Attributed"
    ].freeze

    def initialize(params = {}, created: Time.zone.now, account:)
      coerce_dates(params)
      coerce_data_types(params)
      @created = created
      @account = account

      # We want to limit the available attributes to be a subset of the given attributes; the `&` is
      # the intersection of the two arrays.
      @attributes_to_show = params.fetch(:attributes_to_show, ["Access_Method"]) & ALLOWED_REPORT_ATTRIBUTES_TO_SHOW
    end

    def to_hash
      {
        "Report_Header" => {
          "Release" => "5.1",
          "Report_ID" => "PR",
          "Report_Name" => "Platform Report",
          "Created" => created.rfc3339, # "2023-02-15T09:11:12Z"
          "Created_By" => account.institution_name,
          "Institution_ID" => account.institution_id_data,
          "Institution_Name" => account.institution_name,
          "Registry_Record" => "",
          "Report_Attributes" => {
            "Attributes_To_Show" => attributes_to_show
          },
          "Report_Filters" => {
            # TODO: handle YYYY-MM format
            "Begin_Date" => begin_date.iso8601,
            "End_Date" => end_date.iso8601,
            "Data_Type" => data_types
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
            end,
            "Unique_Item_Investigations" =>
            records.each_with_object({}) do |record, hash|
              hash[record.year_month.strftime("%Y-%m")] = record.unique_item_investigations
              hash
            end,
            "Unique_Item_Requests" =>
            records.each_with_object({}) do |record, hash|
              hash[record.year_month.strftime("%Y-%m")] = record.unique_item_requests
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
    # also, note that unique_item_requests and unique_item_investigations should be counted for Hyrax::CounterMetrics that have unique dates, and unique work IDs.
    # see the docs for counting unique items here: https://cop5.projectcounter.org/en/5.1/07-processing/03-counting-unique-items.html
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
