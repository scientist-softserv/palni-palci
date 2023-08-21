# frozen_string_literal: true

# Creates counter metrics for a single tenant.
class GenerateCounterMetrics
  def self.generate_counter_metrics(ids: :all, limit: :all)
    fsq = "has_model_ssim: (#{Bulkrax.curation_concerns.join(' OR ')})"
    fsq += " AND id:(\"" + Array.wrap(ids).join('" OR "') + "\")" if ids.present? && ids != :all
    message = if ids == :all || ids.blank?
                "Creating test data for #{limit} randomly selected works"
              else
                "Creating test data for works with ids #{ids}"
              end
    options = { fl: "id, has_model_ssim, resource_type_tesim", method: :post }
    options[:rows] = limit if limit.is_a?(Numeric)
    ActiveFedora::SolrService.query(fsq, options).each do |work|
      work_type = work.fetch('has_model_ssim').first
      work_id = work.fetch('id')
      resource_type = work.fetch('resource_type_tesim').first
      (0...90).each do |i|
        date = i.days.ago.to_date
        total_item_investigations = rand(1..10)
        total_item_requests = rand(1..10)

        Hyrax::CounterMetric.create!(
          worktype: work_type,
          work_id: work_id,
          resource_type: resource_type,
          date: date,
          total_item_investigations: total_item_investigations,
          total_item_requests: total_item_requests
        )
      end
    end
    Rails.logger.info message
  end
end
