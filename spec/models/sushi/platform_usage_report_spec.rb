# frozen_string_literal:true

RSpec.describe Sushi::PlatformUsageReport do
  let(:account) { double(Account, institution_name: 'Pitt', institution_id_data: {}, cname: "pitt.edu") }

  describe '#as_json' do
    before { create_hyrax_countermetric_objects }

    subject { described_class.new(params, created: created, account: account).as_json }

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
      expect(subject.dig('Report_Header', 'Report_Filters', 'Begin_Date')).to eq('2022-01-01')
      expect(subject.dig('Report_Header', 'Report_Filters', 'End_Date')).to eq('2022-02-28')
      expect(subject.dig('Report_Items', 'Attribute_Performance').find { |o| o["Data_Type"] == "Platform" }.dig('Performance', 'Searches_Platform', '2022-01')).to eq(5)
    end
  end
end
