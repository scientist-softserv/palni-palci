# frozen_string_literal:true

RSpec.describe Sushi::PlatformReport do
  let(:account) { double(Account, institution_name: 'Pitt', institution_id_data: {}, cname: 'pitt.hyku.test') }

  describe '#to_hash' do
    let(:created) { Time.zone.now }
    subject { described_class.new(params, created: created, account: account).to_hash }

    before { create_hyrax_countermetric_objects }

    context 'with only required params' do
      let(:params) do
        {
          begin_date: '2022-01-03',
          end_date: '2022-02-05'
        }
      end

      it 'has the expected keys' do
        expect(subject).to be_key('Report_Header')
        expect(subject.dig('Report_Header', 'Created')).to eq(created.rfc3339)
        expect(subject.dig('Report_Header', 'Report_Filters', 'Begin_Date')).to eq('2022-01-01')
        expect(subject.dig('Report_Header', 'Report_Filters', 'End_Date')).to eq('2022-02-28')
        expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance', 'Total_Item_Investigations', '2022-01')).to eq(5)
        expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance', 'Total_Item_Requests', '2022-01')).to eq(16)
        expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance', 'Unique_Item_Investigations', '2022-01')).to eq(3)
        expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance', 'Unique_Item_Requests', '2022-01')).to eq(3)
        expect(subject.dig('Report_Items', 'Attribute_Performance').find { |o| o["Data_Type"] == "Platform" }.dig('Performance', 'Searches_Platform', '2022-01')).to eq(5)
      end
    end

    context 'with additional params that are not required' do
      let(:params) do
        {
          begin_date: '2023-08',
          end_date: '2023-09',
          metric_type: 'total_item_investigations|unique_item_investigations|fake_value',
          data_type: 'article',
          attributes_to_show: ['Access_Method', 'Fake_Value'],
        }
      end

      it "only shows the requested metric types, , and does not include metric types that aren't allowed" do
        expect(subject.dig('Report_Header', 'Report_Filters', 'Metric_Type')).to eq(['Total_Item_Investigations', 'Unique_Item_Investigations'])
        expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance')).to have_key('Total_Item_Investigations')
        expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance')).to have_key('Unique_Item_Investigations')
        expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance')).not_to have_key('Total_Item_Requests')
        expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance')).not_to have_key('Unique_Item_Requests')
      end

      it "includes the correct attributes to show, and does not include attributes that aren't allowed" do
        expect(subject.dig('Report_Header', 'Report_Attributes', 'Attributes_To_Show')).to eq(['Access_Method'])
      end

      it 'does not show title requests/investigations for non-book resource types' do
        expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance')).not_to have_key('Unique_Title_Requests')
        expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance')).not_to have_key('Unique_Title_Investigations')
      end
    end
  end
end
