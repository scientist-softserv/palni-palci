# frozen_string_literal:true

# counter compliant format for the PlatformReport is found here: https://countermetrics.stoplight.io/docs/counter-sushi-api/e98e9f5cab5ed-pr-platform-report#Query-Parameters
class Reports::PlatformReport
  attr_reader :created, :account, :attributes_to_show, :begin_date, :end_date, :data_types
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
  ]

  def initialize(created: Time.zone.now, account:, attributes_to_show: [], begin_date:, end_date:, data_types: [])
    @created = created
    @account = account
    @attributes_to_show = attributes_to_show & ALLOWED_REPORT_ATTRIBUTES_TO_SHOW
    @begin_date = begin_date.to_date
    @end_date = end_date.to_date
    @data_types = Array.wrap(data_types)
    # TODO: handle earliest minimum begin date depending on when we find out is the earliest date
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
        "Attribute_Performance" => attribute_performance
      }
    }
  end

  def attribute_performance
    data.group_by(&:resource_type).map do |resource_type, records|
      { "Data_Type" => resource_type,
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
        }
      }
    end
  end

  def data
    relation = Hyrax::CounterMetric
    relation = relation.where(resource_type: data_types) if data_types.present?
    relation = relation.where("date >= ? AND date <= ?", begin_date, end_date)
    relation = relation.order(:resource_type, "year_month")
    relation = relation.group(:resource_type, "date_trunc('month', date)")
    relation = relation.select(:resource_type, "date_trunc('month', date) AS year_month", "SUM(total_item_investigations) as total_item_investigations", "SUM(total_item_requests) as total_item_requests")
  end
end