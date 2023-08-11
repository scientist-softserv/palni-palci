# frozen_string_literal:true

# counter compliant format for ItemReport: https://countermetrics.stoplight.io/docs/counter-sushi-api/5a6e9f5ddae3e-ir-item-report
#
# dates will be filtered where both begin & end dates are inclusive.
# any provided begin_date will be moved to the beginning of the month
# any provided end_date will be moved to the end of the month
module Sushi
  class ItemReport
    attr_reader :created, :account, :attributes_to_show, :data_types
    include Sushi::AttributePerformance
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
          "Report_Name" => "Item Report",
          "Report_ID" => "IR",
          "Release" => "5.1",
          "Institution_Name" => account.institution_name,
          "Institution_ID" => account.institution_id_data,
          "Report_Filters" => {
            # TODO: handle YYYY-MM format
            "Begin_Date" => begin_date.iso8601,
            "End_Date" => end_date.iso8601,
            "Data_Type" => data_types
          },
          "Created" => created.rfc3339, # "2023-02-15T09:11:12Z"
          "Created_By" => account.institution_name,
          "Registry_Record" => "",
          "Report_Attributes" => {
            "Attributes_To_Show" => attributes_to_show
          }
        },
        "Report_Items" => {
          "Attribute_Performance" => attribute_performance_for_resource_types + attribute_performance_for(resource_type: 'Item')
        }
      }
    end
  end
end
