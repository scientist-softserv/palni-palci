# frozen_string_literal: true

# Generated via
#  `rails generate curation_concerns:work Cdl`
RSpec.describe Hyrax::CdlForm do
  let(:work) { Cdl.new }
  let(:form) { described_class.new(work, nil, nil) }
  let(:file_set) { FactoryBot.create(:file_set) }

  describe ".model_attributes" do
    subject { described_class.model_attributes(params) }

    let(:params) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        title: ['foo'],
        rendering_ids: [file_set.id]
      }
    end

    it 'permits parameters' do
      skip
      expect(subject['rendering_ids']).to eq [file_set.id]
    end
  end

  include_examples("work_form")
end