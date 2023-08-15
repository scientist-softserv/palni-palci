# frozen_string_literal:true

RSpec.describe Sushi do
  describe '#coerce_to_date' do
    subject { described_class.coerce_to_date(given_date) }

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

  describe '.first_month_available' do
    subject { described_class.first_month_available }

    let(:entry) do
      Hyrax::CounterMetric.create(
        worktype: 'GenericWork',
        resource_type: 'Book',
        work_id: '12345',
        date: entry_date,
        total_item_investigations: 1,
        total_item_requests: 10
      )
    end

    context 'when first entry date is middle of the month and current date is end of this month' do
      let(:current_date) { Time.zone.today.end_of_month }
      let(:entry_date) { 10.days.ago(current_date) }

      before { entry }

      it 'will return nil (because we have less than one month of data)' do
        expect(subject).to be_nil
      end
    end

    context 'when first entry is the middle of two months ago and current date is middle of this month' do
      let(:current_date) { 10.days.ago(Time.zone.today.end_of_month) }
      let(:entry_date) { 10.days.ago(2.months.ago(Time.zone.today.end_of_month)) }

      before { entry }

      it 'will return the beginning of the month of the earliest entry' do
        expect(subject).to eq(entry_date.beginning_of_month)
      end
    end

    context 'when there are no entries' do
      it { is_expected.to be_nil }
    end
  end

  describe '.last_month_available' do
    subject { described_class.last_month_available }

    let(:entry) do
      Hyrax::CounterMetric.create(
        worktype: 'GenericWork',
        resource_type: 'Book',
        work_id: '12345',
        date: entry_date,
        total_item_investigations: 1,
        total_item_requests: 10
      )
    end
    let(:create_older_entry) do
      # Because sometimes we nee
      Hyrax::CounterMetric.create(
        worktype: 'GenericWork',
        resource_type: 'Book',
        work_id: '12345',
        date: 2.years.ago,
        total_item_investigations: 1,
        total_item_requests: 10
      )
    end

    context 'when we have one month of data and the current date is within that month' do
      let(:current_date) { Time.zone.today.end_of_month }
      let(:entry_date) { 5.days.ago(Time.zone.today.end_of_month) }

      before { entry }
      it { is_expected.to be_nil }
    end

    context 'when last entry date is middle of the month and current date is end of this month' do
      let(:current_date) { Time.zone.today.end_of_month }
      let(:entry_date) { 10.days.ago(current_date) }

      before do
        create_older_entry
        entry
      end
      it 'will use the end of the previous current month' do
        expect(subject).to eq(1.month.ago(current_date).end_of_month)
      end
    end

    context 'when last entry is the middle of two months ago and current date is middle of this month' do
      let(:current_date) { 10.days.ago(Time.zone.today.end_of_month) }
      let(:entry_date) { 10.days.ago(2.months.ago(Time.zone.today.end_of_month)) }

      before do
        create_older_entry
        entry
      end

      it 'will return the end of the month of the last entry' do
        expect(subject).to eq(entry_date.end_of_month)
      end
    end

    context 'when last entry date is beginning of the month and current entry date is beginning of the month' do
      let(:current_date) { Time.zone.today.beginning_of_month }
      let(:entry_date) { Time.zone.today.beginning_of_month }

      before do
        create_older_entry
        entry
      end

      it 'will return the end of the month prior to the last entry' do
        expect(subject).to eq(1.month.ago(current_date).end_of_month)
      end
    end

    context 'when there are no entries' do
      it { is_expected.to be_nil }
    end
  end
end
