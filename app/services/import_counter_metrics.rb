# frozen_string_literal: true

# Import counter views and downloads for a given tenant
class ImportCounterMetrics
  def self.import_investigations
    csv_text = File.read(Rails.root.join('spec','fixtures','csv','pittir-downloads.csv'))
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      # If no work is found, skip this row
      work = ActiveFedora::Base.where(bulkrax_identifier_tesim: row['eprintid']).first
      worktype = work.class
      work_id = work.id
      resource_type = work.resource_type
      date = row['datestamp'].insert(4, '-').insert(7, '-')
      total_item_investigations = row['count']
      counter_investigations = Hyrax::CounterMetric.find_by(work_id: work_id, date: date)
      if counter_investigations.present?
        Hyrax::CounterMetric.update(worktype: worktype, work_id: work_id, resource_type: resource_type, date: date, total_item_investigations: total_item_investigations)
      else
        Hyrax::CounterMetric.create!(worktype: worktype, work_id: work_id, resource_type: resource_type, date: date, total_item_investigations: total_item_investigations)
      end
    end
  end

  def self.import_requests
    csv_text = File.read(Rails.root.join('spec','fixtures','csv','pittir-views.csv'))
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      work = ActiveFedora::Base.where(bulkrax_identifier_tesim: row['eprintid']).first
      worktype = work.class
      work_id = work.id
      resource_type = work.resource_type
      date = row['datestamp'].insert(4, '-').insert(7, '-')
      total_item_requests = row['count']
      counter_requests = Hyrax::CounterMetric.find_by(work_id: work_id, date: date)
      byebug
      if counter_requests.present?
        Hyrax::CounterMetric.update(worktype: worktype, work_id: work_id, resource_type: resource_type, date: date, total_item_requests: total_item_requests)
      else
        Hyrax::CounterMetric.create!(worktype: worktype, work_id: work_id, resource_type: resource_type, date: date, total_item_requests: total_item_requests)
      end
    end
  end
end


# t.string "worktype"
#     t.string "resource_type"
#     t.integer "work_id"
#     t.date "date"
#     t.integer "total_item_investigations"
#     t.integer "total_item_requests"