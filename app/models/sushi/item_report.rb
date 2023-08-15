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
      'Access_Method',
      # These are all the counter compliant query attributes, they are not currently supported in this implementation.
      # 'Institution_Name',
      # 'Customer_ID',
      # 'Country_Name',
      # 'Country_Code',
      # 'Subdivision_Name',
      # 'Subdivision_Code',
      # 'Attributed'
    ].freeze


    def initialize(params = {}, created: Time.zone.now, account:)
      coerce_dates(params)
      coerce_data_types(params)
      @created = created
      @account = account

      # We want to limit the available attributes to be a subset of the given attributes; the `&` is
      # the intersection of the two arrays.
      @attributes_to_show = params.fetch(:attributes_to_show, ['Access_Method']) & ALLOWED_REPORT_ATTRIBUTES_TO_SHOW
    end

    def to_hash
      {
        'Report_Header' => {
          'Report_Name' => 'Item Report',
          'Report_ID' => 'IR',
          'Release' => '5.1',
          'Institution_Name' => account.institution_name,
          'Institution_ID' => account.institution_id_data,
          'Report_Filters' => {
            # TODO: handle YYYY-MM format
            'Begin_Date' => begin_date.iso8601,
            'End_Date' => end_date.iso8601,
            'Data_Type' => data_types
          },
          'Created' => created.rfc3339, # '2023-02-15T09:11:12Z'
          'Created_By' => account.institution_name,
          'Registry_Record' => '',
          'Report_Attributes' => {
            'Attributes_To_Show' => attributes_to_show
          }
        },
        'Report_Items' => report_items
      }
    end

    def report_items
      data_for_resource_types.group_by(&:work_id).map do |work_id, records|
        record = records.first
        {
          'Items' => [{
            'Attribute_Performance' => [{
              'Data_Type' => record.resource_type.titleize,
              'Access_Method' => 'Regular',
              'Performance' => {
                "Total_Item_Investigations" =>
                  records.each_with_object({}) do |r, hash|
                    hash[r.year_month.strftime("%Y-%m")] = r.total_item_investigations
                    hash
                  end,
                "Total_Item_Requests" =>
                  records.each_with_object({}) do |r, hash|
                    hash[r.year_month.strftime("%Y-%m")] = r.total_item_requests
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
              }
            }],
            'Item' => "#{record.work_id}",
            'Publisher' => '',
            'Platform' => account.cname,
            'Item_ID' => {
              'Proprietary': "#{record.work_id}",
              'URI': "#{account.cname}/concern/#{record.worktype.underscore}s/#{record.work_id}"
            }
          }]
        }
      end
    end

    def data_for_resource_types
      relation = Hyrax::CounterMetric
                   .select(:work_id, :resource_type, :worktype,
                     "date_trunc('month', date) AS year_month",
                     "SUM(total_item_investigations) as total_item_investigations",
                     "SUM(total_item_requests) as total_item_requests",
                     "COUNT(DISTINCT CASE WHEN total_item_investigations IS NOT NULL THEN CONCAT(work_id, '_', date::text) END) as unique_item_investigations",
                     "COUNT(DISTINCT CASE WHEN total_item_requests IS NOT NULL THEN CONCAT(work_id, '_', date::text) END) as unique_item_requests")
                   .where("date >= ? AND date <= ?", begin_date, end_date)
                   .order({ resource_type: :asc, work_id: :asc }, "year_month")
                   .group(:work_id, :resource_type, :worktype, "date_trunc('month', date)")

      return relation if data_types.blank?

      relation.where("LOWER(resource_type) IN (?)", data_types)
    end
  end
end
