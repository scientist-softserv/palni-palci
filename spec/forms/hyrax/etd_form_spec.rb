# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Hyrax::EtdForm do
  let(:work) { Etd.new }
  let(:form) { described_class.new(work, nil, nil) }
  let(:file_set) { FactoryBot.create(:file_set) }

  describe '.model_attributes' do
    subject { described_class.model_attributes(params) }

    let(:params) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        title: ['Title'],
        creator: ['Creator'],
        institution: 'Institution',
        year: '2000',
        subject: ['My Subject'],
        resource_type: ['Ceremony'],
        degree: ['Degree'],
        # level: ['Level'],
        discipline: ['Discipline'],
        degree_granting_institution: ['Degree Granting Inst']
      }
    end

    it 'permits paramters' do
      expect(subject['title']).to eq ['Title']
      expect(subject['creator']).to eq ['Creator']
      expect(subject['institution']).to eq 'Institution'
      expect(subject['year']).to eq '2000'
      expect(subject['subject']).to eq ['My Subject']
      expect(subject['resource_type']).to eq ['Ceremony']
      expect(subject['degree']).to eq ['Degree']
      # expect(subject['level']).to eq ['Level']
      expect(subject['discipline']).to eq ['Discipline']
      expect(subject['degree_granting_institution']).to eq ['Degree Granting Inst']
    end
  end
end
