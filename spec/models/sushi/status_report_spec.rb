# frozen_string_literal:true

RSpec.describe Sushi::StatusReport do
  describe '#status_report' do
    let(:account) { double(Account, institution_name: 'Pitt', institution_id_data: {}, cname: 'pitt.hyku.test')}
    let(:created) { Time.zone.now }
    subject { described_class.new(params, created: created, account: account).status_report }

    let(:params) do
      {
        begin_date: '2022-01-03',
        end_date: '2022-02-05'
      }
    end


    it 'returns the correct format' do
      expect(subject).to be_an_instance_of(Array)
      expect(subject.length).to eq(1)
    end

    it 'has the expected keys' do
      expect(subject.first).to have_key('Description')
      expect(subject.first).to have_key('Service_Active')
      expect(subject.first).to have_key('Registry_Record')
      expect(subject.first).to have_key('Alerts')
      expect(subject.first['Alerts'].first).to have_key('Date_Time')
      expect(subject.first['Alerts'].first).to have_key('Alert')
    end

    it 'returns the expected values' do
      expect(subject.first['Description']).to eq("COUNTER Usage Reports for #{account.cname} platform.")
      expect(subject.first['Service_Active']).to eq(true) # will need to be updated when we find out where alerts come from
      expect(subject.first['Registry_Record']).to eq("")
      expect(subject.first['Alerts'].first['Date_Time']).to eq("2016-08-02T12:54:05Z") # will need to be updated when we find out where alerts come from
      expect(subject.first['Alerts'].first['Alert']).to eq("Service will be unavailable Sunday midnight.") # will need to be updated when we find out where alerts come from
    end
  end
end
