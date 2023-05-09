# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Etd do
  it 'has a title' do
    subject.title = ['New Work']
    expect(subject.title).to eq ['New Work']
  end

  it 'has required fields' do
    subject.creator = ['Creator']
    subject.rights_statement = ['In Copyright']
    subject.institution = 'Institution'
    subject.date_created = ['2000']
    subject.subject = ['My Subject']
    subject.resource_type = ['Ceremony']
    subject.degree = ['Degree']
    subject.level = ['Level']
    subject.discipline = ['Discipline']
    subject.degree_granting_institution = ['Degree Granting Inst']

    expect(subject.creator).to eq ['Creator']
    expect(subject.rights_statement).to eq ['In Copyright']
    expect(subject.institution).to eq 'Institution'
    expect(subject.date_created).to eq ['2000']
    expect(subject.subject).to eq ['My Subject']
    expect(subject.resource_type).to eq ['Ceremony']
    expect(subject.degree).to eq ['Degree']
    expect(subject.level).to eq ['Level']
    expect(subject.discipline).to eq ['Discipline']
    expect(subject.degree_granting_institution).to eq ['Degree Granting Inst']
  end

  describe 'metadata' do
    it 'responds to metadata items' do
      expect(subject).to respond_to(:title)
      expect(subject).to respond_to(:creator)
      expect(subject).to respond_to(:rights_statement)
      expect(subject).to respond_to(:institution)
    end
  end
end
