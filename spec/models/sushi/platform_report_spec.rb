# frozen_string_literal:true

RSpec.describe Sushi::PlatformReport do
  let(:account) { double(Account, institution_name: 'Pitt', institution_id_data: {}) }

  describe '#to_hash' do
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
        date: '2022-01-05',
        total_item_investigations: 3,
        total_item_requests: 5
      )
    end

    subject { described_class.new(params, created: created, account: account).to_hash }

    let(:params) do
      {
        attributes_to_show: ['Access_Method', 'Fake_Value'],
        begin_date: '2022-01-03',
        end_date: '2022-02-05'
      }
    end

    let(:created) { Time.zone.now }

    it 'has the expected keys' do
      expect(subject).to be_key('Report_Header')
      expect(subject.dig('Report_Header', 'Created')).to eq(created.rfc3339)
      expect(subject.dig('Report_Header', 'Report_Attributes', 'Attributes_To_Show')).to eq(['Access_Method'])
      expect(subject.dig('Report_Header', 'Report_Filters', 'Begin_Date')).to eq('2022-01-03')
      expect(subject.dig('Report_Header', 'Report_Filters', 'End_Date')).to eq('2022-02-05')
      expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance', 'Total_Item_Investigations', '2022-01')).to eq(4)
    end
  end

  describe '.coerce_to_date' do
    subject { Sushi.coerce_to_date(given_date) }

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
end