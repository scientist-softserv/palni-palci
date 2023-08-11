# frozen_string_literal:true

# counter compliant format for ItemReport: https://countermetrics.stoplight.io/docs/counter-sushi-api/5a6e9f5ddae3e-ir-item-report
#
# dates will be filtered where both begin & end dates are inclusive.
# any provided begin_date will be moved to the beginning of the month
# any provided end_date will be moved to the end of the month
module Sushi
  class ItemReport
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
        "Report_Items" => report_items
      }
    end

    def report_items
      # get all works in the db
      # map over each work (grouping them together by type?) to return an array of hashes with these required properties:
      #
      # {
      #   "Title" =>       string
      #                    title of the work
      #
      #   "Item_ID" =>      hash
      #                     Identifier of a specific title usage is being requested for. If omitted, all titles on the platform with usage for the customer will be returned.
      #                     e.g. { "DOI":"10.9999/xxxxt01", "Proprietary":"P1:T01", "ISBN":"979-8-88888-888-8", "URI":"https://doi.org/10.9999/xxxxt01" }
      #
      #   "Items" =>       array of hashes
      #                    are the items, child works?
      # }
    end

    def items(child_works:)
      # assuming this method is the value of the "Items" key above
      # we need to map over each child work and also return an array of hashes with these required properties:
      #
      # {
      #   "Attribute_Performance" =>     array of hashes
      #                                  { "Data_Type": "Book_Segment", "Performance": { what we're doing in the other reports }}
      #
      #   "Item" =>                      string,
      #                                  child work name?
      #
      #   "Publisher" =>                 string,
      #                                  which value should be use here?
      #
      #   "Platform" =>                  string,
      #                                  Name of the platform the report data is being requested for. Might be required if a SUSHI server provides usage data for multiple platforms.
      #                                  what should we use for this?
      # }
    end
  end
end
