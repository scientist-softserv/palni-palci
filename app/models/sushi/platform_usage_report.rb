# frozen_string_literal:true

# counter compliant format for the PlatformReport is found here: https://countermetrics.stoplight.io/docs/counter-sushi-api/e98e9f5cab5ed-pr-platform-report#Query-Parameters
#
# dates will be filtered by including the begin_date, and excluding the end_date
# e.g. if you want to full month, begin_date should be the first day of that month, and end_date should be the first day of the following month.
module Sushi
  class PlatformUsageReport
    attr_reader :created, :account
    include Sushi::AttributePerformance
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
          "Attribute_Performance" => attribute_performance_for_resource_types + attribute_performance_for(resource_type: 'Platform')
        }
      }
    end
  end
end
