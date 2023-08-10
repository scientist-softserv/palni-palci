# frozen_string_literal:true

# counter compliant format for the PlatformReport is found here: https://countermetrics.stoplight.io/docs/counter-sushi-api/e98e9f5cab5ed-pr-platform-report#Query-Parameters
module Sushi
  class ReportsReport
    #   attr_reader :begin_date, :end_date

    # def initialize #(begin_date:, end_date:)
    # Will need to get earliest and latest available dates from the database
    # @begin_date = begin_date.to_date
    # @end_date = end_date.to_date
    # end

    # rubocop:disable Metrics/MethodLength, Metrics/LineLength
    def reports_array
      [
        {
          "Report_Name" => "Status Report",
          "Report_ID" => "STATUS",
          "Release" => "5.1",
          "Report_Description" => "This resource returns the current status of the reporting service supported by this API.",
          "Path" => "/api/sushi/r51/status"
        },
        {
          "Report_Name" => "Members Report",
          "Report_ID" => "MEMBERS",
          "Release" => "5.1",
          "Report_Description" => "This resource returns the list of consortium members related to a Customer_ID.",
          "Path" => "/api/sushi/r51/members"
        },
        {
          "Report_Name" => "Reports Report",
          "Report_ID" => "REPORTS",
          "Release" => "5.1",
          "Report_Description" => "This resource returns a list of reports supported by the API for a given application.",
          "Path" => "/api/sushi/r51/reports"
        },
        {
          "Report_Name" => "Platform Report",
          "Report_ID" => "PR",
          "Release" => "5.1",
          "Report_Description" => "This resource returns COUNTER 'Platform Master Report' [PR]. A customizable report summarizing activity across a provider’s platforms that allows the user to apply filters and select other configuration options for the report.",
          "Path" => "api/sushi/r51/reports/pr",
          "First_Month_Available" => Sushi.first_month_available,
          "Last_Month_Available" => Sushi.last_month_available
        },
        {
          "Report_Name" => "Platform Usage Report",
          "Report_ID" => "PR_P1",
          "Release" => "5.1",
          "Report_Description" => "This resource returns COUNTER 'Platform Usage' [pr_p1]. This is a Standard View of the Package Master Report that presents usage for the overall Platform broken down by Metric_Type.",
          "Path" => "/api/sushi/r51/reports/pr_p1",
          "First_Month_Available" => Sushi.first_month_available,
          "Last_Month_Available" => Sushi.last_month_available
        },
        {
          "Report_Name" => "Item Report",
          "Report_ID" => "IR",
          "Release" => "5.1",
          "Report_Description" => "This resource returns COUNTER 'Item Master Report' [IR].",
          "Path" => "/api/sushi/r51/reports/ir",
          "First_Month_Available" => Sushi.first_month_available,
          "Last_Month_Available" => Sushi.last_month_available
        }
      ]
    end
    # rubocop:enable Metrics/MethodLength, Metrics/LineLength
  end
end
