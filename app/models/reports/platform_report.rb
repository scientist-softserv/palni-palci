# frozen_string_literal:true

# counter compliant format for the PlatformReport is found here: https://countermetrics.stoplight.io/docs/counter-sushi-api/e98e9f5cab5ed-pr-platform-report#Query-Parameters
#
# dates will be filtered by including the begin_date, and excluding the end_date
# e.g. if you want to full month, begin_date should be the first day of that month, and end_date should be the first day of the following month.
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

  def self.build_from(params = {}, account:)
    begin_date = params.fetch(:begin_date)
    end_date = params.fetch(:end_date)
    # data_type: a list of Data_Types separated by the | character (URL encoded as %7C) to return usage for. when omitted, includes all Data_Types.
    # ex. 'book|article|audio'
    data_types = params[:data_type]&.split('|')
    new(begin_date: begin_date, end_date: end_date, data_types: data_types, account: account)
  end

  def self.coerce_to_date(value)
    value.to_date
  rescue
    year, month, rest = value.split('-')
    Date.new(year.to_i, month.to_i, 1)
  end

  def initialize(created: Time.zone.now, account:, attributes_to_show: [], begin_date:, end_date:, data_types: [])
    @created = created
    @account = account
    @attributes_to_show = attributes_to_show & ALLOWED_REPORT_ATTRIBUTES_TO_SHOW
    @begin_date = self.class.coerce_to_date(begin_date)
    @end_date = self.class.coerce_to_date(end_date)
    # Array.wrap handles whether there is an array or a string. If its a string, it turns it into an array.
    @data_types = Array.wrap(data_types).map(&:downcase)
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
        }
      }
    end
  end

  def data
    relation = Hyrax::CounterMetric
    relation = relation.where("LOWER(resource_type) IN (?)", data_types) if data_types.present?
    relation = relation.where("date >= ? AND date < ?", begin_date, end_date)
    relation = relation.order(:resource_type, "year_month")
    relation = relation.group(:resource_type, "date_trunc('month', date)")
    relation = relation.select(:resource_type, "date_trunc('month', date) AS year_month", "SUM(total_item_investigations) as total_item_investigations", "SUM(total_item_requests) as total_item_requests")
  end
end