require 'spec_helper'

RSpec.describe Collection do
  it "is a hyrax collection" do
    expect(described_class.ancestors).to include Hyrax::CollectionBehavior
  end

  describe ".indexer" do
    subject { described_class.indexer }

    it { is_expected.to eq CollectionIndexer }
  end

  describe 'metadata properties' do
    it { is_expected.to have_property(:bulkrax_identifier).with_predicate("https://hykucommons.org/terms/bulkrax_identifier") }
  end
end
