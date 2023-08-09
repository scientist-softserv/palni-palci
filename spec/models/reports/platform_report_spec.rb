RSpec.describe Reports::PlatformReport do
  describe '#to_hash' do
    before do
      Hyrax::CounterMetric.create(
        worktype: "GenericWork",
        resource_type: "Book",
        work_id: "12345",
        date: "2022-01-05",
        total_item_investigations: 1,
        total_item_requests: 10)
      Hyrax::CounterMetric.create(
        worktype: "GenericWork",
        resource_type: "Book",
        work_id: "54321",
        date: "2022-01-05",
        total_item_investigations: 3,
        total_item_requests: 5)
    end

    let(:created) { Time.zone.now }
    let(:account) { double(Account, institution_name: "Pitt", institution_id_data: {}) }
    subject { described_class.new(
      created: created,
      account: account,
      attributes_to_show: ["Access_Method", "Fake_Value"],
      begin_date: "2022-01-03",
      end_date: "2022-02-05"
    ).to_hash }

    it 'has the expected keys' do
      expect(subject.key?("Report_Header"))
      expect(subject.dig("Report_Header", "Created")).to eq(created.rfc3339)
      expect(subject.dig("Report_Header", "Report_Attributes", "Attributes_To_Show")).to eq(["Access_Method"])
      expect(subject.dig("Report_Header", "Report_Filters", "Begin_Date")).to eq("2022-01-03")
      expect(subject.dig("Report_Header", "Report_Filters", "End_Date")).to eq("2022-02-05")
      expect(subject.dig("Report_Items", "Attribute_Performance").first.dig("Performance", "Total_Item_Investigations", "2022-01-05")).to eq(4)
    end
  end
end