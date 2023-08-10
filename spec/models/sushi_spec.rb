# frozen_string_literal:true

RSpec.describe Sushi do
  describe '.coerce_to_date' do
    subject { described_class.coerce_to_date(given_date) }

    context 'with 2023-02-01' do
      let(:given_date) { '2023-02-01' }

      it { is_expected.to eq(Date.new(2023, 2, 1)) }
    end
    context 'with 2023-05' do
      let(:given_date) { '2023-05' }

      it { is_expected.to eq(Date.new(2023, 5, 1)) }
    end
    context 'with 2023' do
      let(:given_date) { '2023' }

      it 'will raise an error' do
        expect { subject }.to raise_exception(Sushi::InvalidParameterValue)
      end
    end
  end

  describe 'the available date range for any given report' do
    before do
      Hyrax::CounterMetric.create(
        worktype: 'GenericWork',
        resource_type: 'Book',
        work_id: '12345',
        date: '2022-01-05',
        total_item_investigations: 1,
        total_item_requests: 10
      )
      Hyrax::CounterMetric.create(
        worktype: 'GenericWork',
        resource_type: 'Book',
        work_id: '54321',
        date: '2023-01-05',
        total_item_investigations: 3,
        total_item_requests: 5
      )
    end

    context '.first_month_available' do
      subject { described_class.first_month_available }
      it { is_expected.to eq('2022-01') }
    end

    context '.last_month_available' do
      subject { described_class.last_month_available }
      it { is_expected.to eq('2023-01') }
    end
  end
end
