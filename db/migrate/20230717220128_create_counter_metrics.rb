class CreateCounterMetrics < ActiveRecord::Migration[5.2]
  def change
    create_table :counter_metrics do |t|
      t.string :worktype
      t.string :resource_type
      t.string :work_id
      t.string :date
      t.string :total_item_investigations
      t.string :total_item_requests
    end
  end
end
