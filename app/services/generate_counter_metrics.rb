# frozen_string_literal: true

# Import counter views and downloads for a given tenant
# Currently, this only imports the first resource type. Additional work would need to be done for works with multiple resource types.
# The resource_type field in the counter_metrics table is single value and not an array.
class GenerateCounterMetrics
  def self.generate_counter_metrics(ids: 'all', limit: 10)
    if ids == 'all' || ids.blank?
      test_works = GenericWork.all.to_a.sample(limit)

      while test_works.length < limit
        test_works.concat(test_works.sample(limit - test_works.length))
      end

      message = "Creating test data for #{limit} randomly selected GenericWorks"
    else
      test_works = ActiveFedora::Base.where(id: ids).to_a
      message = "Creating test data for works with ids #{ids}"
    end
    puts message
    test_works.each do |work|
      worktype = work.class
      work_id = work.id
      resource_type = work.resource_type.first
      date = random_date_in_last_3_months
      total_item_investigations = rand(1..10)
      total_item_requests = rand(1..10)
      Hyrax::CounterMetric.create!(
        worktype: worktype,
        work_id: work_id,
        resource_type: resource_type,
        date: date,
        total_item_investigations: total_item_investigations,
        total_item_requests: total_item_requests
      )
    end
  end

  def self.random_date_in_last_3_months
    random_days_ago = rand(1..90) # 90 days in 3 months
    random_date = Date.today - random_days_ago
    random_date.strftime("%Y%m%d")
  end
end
