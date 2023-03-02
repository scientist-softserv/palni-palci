# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`

RSpec.describe Image do
  include_examples('includes OrderMetadataValues')

  describe 'indexer' do
    subject { described_class.indexer }

    it { is_expected.to eq ImageIndexer }
  end

  describe "metadata" do
    it { is_expected.to have_property(:bulkrax_identifier).with_predicate("https://hykucommons.org/terms/bulkrax_identifier") }
  end
end
