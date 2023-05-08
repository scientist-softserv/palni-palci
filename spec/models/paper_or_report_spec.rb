# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work PaperOrReport`
require 'rails_helper'

RSpec.describe PaperOrReport do
  it "has a title" do
    subject.title = ["New Work"]
    expect(subject.title).to eq ["New Work"]
  end
  it "has required fields" do
    subject.creator = ['Creator']
    subject.rights_statement = ['In Copyright']
    subject.institution = 'Institution'
    expect(subject.creator).to eq ['Creator']
    expect(subject.rights_statement).to eq ['In Copyright']
    expect(subject.institution).to eq 'Institution'
  end

  it "has date created as single value field" do
    subject.date_created = ["2002"]
    expect(subject.date_created).to eq ["2002"]
  end

  describe "metadata" do
    it "responds to metadata items" do
      expect(subject).to respond_to(:title)
      expect(subject).to respond_to(:creator)
      expect(subject).to respond_to(:rights_statement)
      expect(subject).to respond_to(:institution)
    end
  end
end
