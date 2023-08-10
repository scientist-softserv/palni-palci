# frozen_string_literal:true

RSpec.describe Sushi do
  describe '.coerce_to_date' do
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
end
