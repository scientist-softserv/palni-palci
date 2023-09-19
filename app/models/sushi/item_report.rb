# frozen_string_literal:true

# counter compliant format for ItemReport: https://countermetrics.stoplight.io/docs/counter-sushi-api/5a6e9f5ddae3e-ir-item-report
#
# dates will be filtered where both begin & end dates are inclusive.
# any provided begin_date will be moved to the beginning of the month
# any provided end_date will be moved to the end of the month
module Sushi
  class ItemReport
    attr_reader :account, :attributes_to_show, :created
    include Sushi::AccessMethodCoercion
    include Sushi::AuthorCoercion
    include Sushi::DateCoercion
    include Sushi::DataTypeCoercion
    include Sushi::DateCoercion
    include Sushi::ItemIDCoercion
    include Sushi::MetricTypeCoercion
    include Sushi::PlatformCoercion
    include Sushi::YearOfPublicationCoercion

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

    ALLOWED_METRIC_TYPES = [
      'Total_Item_Investigations',
      'Total_Item_Requests',
      'Unique_Item_Investigations',
      'Unique_Item_Requests'
    ].freeze

    def initialize(params = {}, created: Time.zone.now, account:)
      coerce_access_method(params)
      coerce_author(params)
      coerce_data_types(params)
      coerce_dates(params)
      coerce_item_id(params)
      coerce_metric_types(params, allowed_types: ALLOWED_METRIC_TYPES)
      coerce_platform(params, account)
      coerce_yop(params)
      @account = account
      @created = created

      # We want to limit the available attributes to be a subset of the given attributes; the `&` is
      # the intersection of the two arrays.
      @attributes_to_show = params.fetch(:attributes_to_show, ['Access_Method']) & ALLOWED_REPORT_ATTRIBUTES_TO_SHOW
    end

    def as_json(_options = {})
      report_hash = {
        'Report_Header' => {
          'Report_Name' => 'Item Report',
          'Report_ID' => 'IR',
          'Release' => '5.1',
          'Institution_Name' => account.institution_name,
          'Institution_ID' => account.institution_id_data,
          'Report_Filters' => {
            'Begin_Date' => begin_date.iso8601,
            'End_Date' => end_date.iso8601
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

      raise Sushi::Error::NoUsageAvailableForRequestedDatesError.new(data: "No data within #{begin_date.iso8601} and #{end_date.iso8601} date range.") if report_items.blank?

      report_hash['Report_Header']['Report_Filters']['Access_Method'] = access_methods if access_method_in_params
      report_hash['Report_Header']['Report_Filters']['Author'] = author if author_in_params
      report_hash['Report_Header']['Report_Filters']['Data_Type'] = data_types if data_type_in_params
      report_hash['Report_Header']['Report_Filters']['Item_ID'] = item_id if item_id_in_params
      report_hash['Report_Header']['Report_Filters']['Metric_Type'] = metric_types if metric_type_in_params
      report_hash['Report_Header']['Report_Filters']['Platform'] = platform if platform_in_params
      report_hash['Report_Header']['Report_Filters']['YOP'] = yop if yop

      report_hash
    end

    alias to_hash as_json

    def report_items
      data_for_resource_types.map do |record|
        {
          'Items' => [{
            'Attribute_Performance' => [{
              'Data_Type' => record.resource_type.titleize,
              # We are only supporting the 'Regular' access method at this time. If that changes, we will need to update this.
              'Access_Method' => 'Regular',
              'Performance' => performance(record)
            }],
            'Authors' => Sushi::AuthorCoercion.deserialize(record.author).map { |author| { 'Name:' => author } },
            'Item' => record.work_id.to_s,
            'Publisher' => '',
            'Platform' => account.cname,
            'Item_ID' => {
              'Proprietary': record.work_id.to_s,
              'URI': "https://#{account.cname}/concern/#{record.worktype.underscore}s/#{record.work_id}"
            }
          }]
        }
      end
    end

    def performance(record)
      metric_types.each_with_object({}) do |metric_type, returning_hash|
        returning_hash[metric_type] = record.performance.each_with_object({}) do |cell, hash|
          hash[cell.fetch('year_month')] = cell.fetch(metric_type)
        end
      end
    end

    def data_for_resource_types
      relation = Hyrax::CounterMetric
                 .select(:work_id, :resource_type, :worktype, :author,
                         %((SELECT To_json(Array_agg(Row_to_json(t)))
                           FROM
                           (SELECT
                           -- The AS field_name needs to be double quoted so as to preserve case structure.
                           SUM(total_item_investigations) as "Total_Item_Investigations",
                           SUM(total_item_requests) as "Total_Item_Requests",
                           COUNT(DISTINCT CASE WHEN total_item_investigations IS NOT NULL THEN CONCAT(work_id, '_', date::text) END) as "Unique_Item_Investigations",
                           COUNT(DISTINCT CASE WHEN total_item_requests IS NOT NULL THEN CONCAT(work_id, '_', date::text) END) as "Unique_Item_Requests",
                           -- We need to coerce the month from a single digit to two digits (e.g. August's "8" into "08")
                           CONCAT(DATE_PART('year', date_trunc('month', date)), '-', to_char(DATE_PART('month', date_trunc('month', date)), 'fm00')) AS year_month
                           FROM hyrax_counter_metrics AS aggr
                           WHERE  aggr.work_id = hyrax_counter_metrics.work_id
    	               GROUP BY date_trunc('month', date)) t) as performance))
                 .where("date >= ? AND date <= ?", begin_date, end_date)
                 .order(resource_type: :asc, work_id: :asc)
                 .group(:work_id, :resource_type, :worktype, :author)

      relation = relation.where("(?) = work_id", item_id) if item_id
      relation = relation.where(author_as_where_parameters) if author.present?
      relation = relation.where(yop_as_where_parameters) if yop_as_where_parameters.present?
      relation = relation.where("LOWER(resource_type) IN (?)", data_types) if data_types.any?

      relation
    end
  end
end
