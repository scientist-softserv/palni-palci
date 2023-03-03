# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
require 'rails_helper'
require 'order_already/spec_helper'

RSpec.describe Image do
  include_examples('includes OrderMetadataValues')

  describe 'indexer' do
    subject { described_class.indexer }

    it { is_expected.to eq ImageIndexer }
  end

  describe "metadata" do
    it { is_expected.to have_property(:bulkrax_identifier).with_predicate("https://hykucommons.org/terms/bulkrax_identifier") }
  end

  it { is_expected.to have_already_ordered_attributes(*described_class.multi_valued_properties_for_ordering) }
end
