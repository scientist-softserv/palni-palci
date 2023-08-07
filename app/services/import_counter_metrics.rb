# frozen_string_literal: true

# Import counter views and downloads for a given tenant
class ImportCounterMetrics
  def self.import_investigations(csv_path)
    CSV.foreach(csv_path, headers: true) do |row|
      work = ActiveFedora::Base.where(bulkrax_identifier_tesim: row['eprintid']).first
      next if work.nil?
      worktype = work.class
      work_id = work.id
      resource_type = work.resource_type
      date = row['datestamp']
      total_item_investigations = row['count']
      counter_investigation = Hyrax::CounterMetric.find_by(work_id: work_id, date: date)
      if counter_investigation.present?
        counter_investigation.update(worktype: worktype, work_id: work_id, resource_type: resource_type, date: date, total_item_investigations: total_item_investigations)
      else
        Hyrax::CounterMetric.create!(worktype: worktype, work_id: work_id, resource_type: resource_type, date: date, total_item_investigations: total_item_investigations)
      end
    end
  end

  def self.import_requests(csv_path)
    CSV.foreach(csv_path, headers: true) do |row|
      work = ActiveFedora::Base.where(bulkrax_identifier_tesim: row['eprintid']).first
      next if work.nil?
      worktype = work.class
      work_id = work.id
      resource_type = work.resource_type
      date = row['datestamp']
      total_item_requests = row['count']
      counter_request = Hyrax::CounterMetric.find_by(work_id: work_id, date: date)
      if counter_request.present?
        counter_request.update(worktype: worktype, work_id: work_id, resource_type: resource_type, date: date, total_item_requests: total_item_requests)
      else
        Hyrax::CounterMetric.create!(worktype: worktype, work_id: work_id, resource_type: resource_type, date: date, total_item_requests: total_item_requests)
      end
    end
  end
end
