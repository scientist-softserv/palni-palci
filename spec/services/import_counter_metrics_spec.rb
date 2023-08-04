require 'rails_helper'

RSpec.describe ImportCounterMetrics do
  # TODO: Write tests for this service
  it 'creates Hyrax::CounterMetrics with investigations' do
    ImportCounterMetrics.import_investigations
    expect(Hyrax::CounterMetric.count).not_to be_nil
  end

  it 'creates Hyrax::CounterMetrics with requests' do
    ImportCounterMetrics.import_requests
    expect(Hyrax::CounterMetric.count).not_to be_nil
  end
end
