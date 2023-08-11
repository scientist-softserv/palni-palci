# frozen_string_literal:true

RSpec.describe Sushi::ItemReport do
  let(:account) { double(Account, institution_name: 'Pitt', institution_id_data: {}) }

  describe '#to_hash' do
    before { create_hyrax_countermetric_objects }

    subject { described_class.new(params, created: created, account: account).to_hash }

    let(:params) do
      {
        attributes_to_show: ['Access_Method', 'Fake_Value'],
        begin_date: '2022-01-03',
        end_date: '2023-08-09'
      }
    end

    let(:created) { Time.zone.now }

    it 'has the expected properties' do
      expect(subject).to be_key('Report_Header')
      expect(subject.dig('Report_Header', 'Report_Name')).to eq('Item Report')
      expect(subject.dig('Report_Header', 'Created')).to eq(created.rfc3339)
      expect(subject.dig('Report_Header', 'Report_Attributes', 'Attributes_To_Show')).to eq(['Access_Method'])
      expect(subject.dig('Report_Header', 'Report_Filters', 'Begin_Date')).to eq('2022-01-01')
      expect(subject.dig('Report_Header', 'Report_Filters', 'End_Date')).to eq('2023-08-31')
      # expect(subject.dig('Report_Items', 'Attribute_Performance').first.dig('Performance', 'Total_Item_Investigations', '2023-08')).to eq(2)
      # expect(subject.dig('Report_Items', 'Attribute_Performance').find { |o| o["Data_Type"] == "Item" }.dig('Performance', 'Searches_Item', '2023-08')).to eq(2)
    end
  end
end
