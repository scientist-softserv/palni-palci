RSpec.describe Sushi::ReportInformation do
  describe '#reports_array' do
    before { create_hyrax_countermetric_objects }

    subject { described_class.new.reports_array }

    it 'has the expected keys' do
      expect(subject).to be_an_instance_of(Array)
      expect(subject.first['Report_Name']).to eq('Status Report')
      expect(subject.first['Report_ID']).to eq('STATUS')
      expect(subject.first['Release']).to eq('5.1')
      expect(subject.first['Report_Description']).to eq('This resource returns the current status of the reporting service supported by this API.')
      expect(subject.first['Path']).to eq('/api/sushi/r51/status')
      expect(subject.last['First_Month_Available']).to eq('2022-01')
      expect(subject.last['Last_Month_Available']).to eq('2023-08')
    end
  end
end
