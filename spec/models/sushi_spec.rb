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

  describe "YearOfPublicationCoercion" do
    subject(:instance) { klass.new(params) }

    let(:klass) do
      Class.new do
        include Sushi::YearOfPublicationCoercion
        def initialize(params = {})
          coerce_yop(params)
        end
      end
    end

    let(:params) { {} }

    it { is_expected.to respond_to(:yop_as_where_parameters) }

    context 'when no :yop is provided' do
      its(:yop_as_where_parameters) { is_expected.to be_falsey }
    end

    # rubocop:disable Metrics/LineLength
    [
      ['2003', ["((year_of_publication = ?))", 2003]],
      ['2003-2005', ["((year_of_publication >= ? AND year_of_publication <= ?))", 2003, 2005]],
      ['2003a-2005', Sushi::InvalidParameterValue],
      ['-1', ["((year_of_publication = ?))", -1]],
      ['a-1', Sushi::InvalidParameterValue],
      ['a1', Sushi::InvalidParameterValue],
      ['1-2 3', Sushi::InvalidParameterValue],
      ['1 2', Sushi::InvalidParameterValue],
      ['1996-1994', ["((year_of_publication >= ? AND year_of_publication <= ?))", 1996, 1994]],
      ['1996-1994 | 1999-2003|9a', Sushi::InvalidParameterValue],
      ['1996-1994 | 1299-2003|9-12', ["((year_of_publication >= ? AND year_of_publication <= ?) OR (year_of_publication >= ? AND year_of_publication <= ?) OR (year_of_publication >= ? AND year_of_publication <= ?))", 1996, 1994, 1299, 2003, 9, 12]],
      ['1994-1996 | 1989', ["((year_of_publication >= ? AND year_of_publication <= ?) OR (year_of_publication = ?))", 1994, 1996, 1989]]
    ].each do |given_yop, expected|
      context "when given :yop parameter is #{given_yop.inspect}" do
        let(:params) { { yop: given_yop } }

        if expected.is_a?(Array)
          its(:yop_as_where_parameters) { is_expected.to match_array(expected) }
        else
          it "raises an #{expected}" do
            expect { subject }.to raise_error(expected)
          end
        end
      end
    end
    # rubocop:enable Metrics/LineLength
  end
end
