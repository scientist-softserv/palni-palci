RSpec.describe Reports::PlatformReport do
  describe '#to_hash' do
    let(:created) { Time.zone.now }
    let(:account) { double(Account, institution_name: "Pitt", institution_id_data: {}) }
    subject { described_class.new(
      created: created,
      account: account,
      attributes_to_show: ["Access_Method", "Fake_Value"],
      begin_date: "2022-01-03",
      end_date: "2023-02-05"
    ).to_hash }

    it 'has the expected keys' do
      expect(subject.key?("Report_Header"))
      expect(subject.dig("Report_Header", "Created")).to eq(created.rfc3339)
      expect(subject.dig("Report_Header", "Report_Attributes", "Attributes_To_Show")).to eq(["Access_Method"])
      expect(subject.dig("Report_Header", "Report_Filters", "Begin_Date")).to eq("2022-01-03")
      expect(subject.dig("Report_Header", "Report_Filters", "End_Date")).to eq("2023-02-05")
    end
  end
end