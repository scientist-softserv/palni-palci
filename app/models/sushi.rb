# frozen_string_literal:true

module Sushi
  class << self
    def first_month_available
      Hyrax::CounterMetric.order('date ASC').first.date.strftime('%Y-%m')
    end

    def last_month_available
      Hyrax::CounterMetric.order('date DESC').first.date.strftime('%Y-%m')
    end
  end
end
