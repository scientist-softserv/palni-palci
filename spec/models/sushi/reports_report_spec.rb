RSpec.describe Sushi::ReportsReport do
  describe '#reports_array' do
    subject { described_class.new.reports_array }

    it 'has the expected keys' do
      expect(subject).to be_an_instance_of(Array)
      expect(subject.first['Report_Name']).to eq('Status Report')
      expect(subject.first['Report_ID']).to eq('STATUS')
      expect(subject.first['Release']).to eq('5.1')
      expect(subject.first['Report_Description']).to eq('This resource returns the current status of the reporting service supported by this API.')
      expect(subject.first['Path']).to eq('/api/sushi/r51/status')
    end
  end
end
