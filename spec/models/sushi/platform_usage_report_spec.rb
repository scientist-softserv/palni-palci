# frozen_string_literal:true

RSpec.describe Sushi::PlatformUsageReport do
  let(:account) { double(Account, institution_name: 'Pitt', institution_id_data: {}, cname: "pitt.edu") }
  let(:created) { Time.zone.now }

  describe '#as_json' do
    before { create_hyrax_countermetric_objects }

    subject { described_class.new(params, created: created, account: account).as_json }

    context 'with only required params' do
      let(:params) do
        {
          attributes_to_show: ['Access_Method', 'Fake_Value'],
          begin_date: '2022-01-03',
          end_date: '2022-02-05'
        }
      end

      it 'has the expected keys' do
        expect(subject).to be_key('Report_Header')
        expect(subject.dig('Report_Header', 'Created')).to eq(created.rfc3339)
        expect(subject.dig('Report_Header', 'Report_Filters', 'Begin_Date')).to eq('2022-01-01')
        expect(subject.dig('Report_Header', 'Report_Filters', 'End_Date')).to eq('2022-02-28')
        expect(subject.dig('Report_Items', 'Attribute_Performance').find { |o| o["Data_Type"] == "Platform" }.dig('Performance', 'Searches_Platform', '2022-01')).to eq(6)
      end
    end

    context 'with additional params that are not required' do
      let(:params) do
        {
          begin_date: '2023-08',
          end_date: '2023-09',
          metric_type: 'total_item_investigations|total_item_requests|fake_value',
          attributes_to_show: ['Access_Method', 'Fake_Value']
        }
      end

      # Platform usage report should NOT show investigations, even if it is passed in the params.
      it "only shows the requested metric types, and does not include metric types that aren't allowed" do
        expect(subject.dig('Report_Header', 'Report_Filters', 'Metric_Type')).to eq(['Total_Item_Requests'])
        expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance')).to have_key('Total_Item_Requests')
        expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance')).not_to have_key('Unique_Item_Requests')
        expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance')).not_to have_key('Total_Item_Investigations')
        expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance')).not_to have_key('Unique_Item_Investigations')
      end
    end
  end

  describe 'with an unrecognized parameter' do
    let(:params) {{ other: 'nope' }}

    it 'raises an error' do
      expect { described_class.new(params, created: created, account: account).as_json }.to raise_error(Sushi::Error::UnrecognizedParameterError)
    end
  end
end
