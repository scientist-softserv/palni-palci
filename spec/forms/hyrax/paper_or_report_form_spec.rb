# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work PaperOrReport`
require 'rails_helper'

RSpec.describe Hyrax::PaperOrReportForm do
  let(:work) { PaperOrReport.new }
  let(:form) { described_class.new(work, nil, nil) }
  let(:file_set) { FactoryBot.create(:file_set) }

  describe '.model_attributes' do
    subject { described_class.model_attributes(params) }

    let(:params) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        title: ['Title'],
        creator: ['Creator'],
        institution: 'Institution'
      }
    end

    it 'permits paramters' do
      expect(subject['title']).to eq ['Title']
      expect(subject['creator']).to eq ['Creator']
      expect(subject['institution']).to eq 'Institution'
    end
  end
end
