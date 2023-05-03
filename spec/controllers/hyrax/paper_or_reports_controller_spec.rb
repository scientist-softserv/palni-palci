# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work PaperOrReport`
require 'rails_helper'

RSpec.describe Hyrax::PaperOrReportsController do
  let(:user) { FactoryBot.create(:user) }
  let(:work) { FactoryBot.create(:paper_or_report_with_one_file, user: user) }
  let(:file_set) { work.ordered_members.to_a.first }

  before do
    Hydra::Works::AddFileToFileSet.call(file_set,
                                        fixture_file('images/world.png'),
                                        :original_file)
  end

  describe "#presenter" do
    subject { controller.send :presenter }

    let(:solr_document) { SolrDocument.new(FactoryBot.create(:paper_or_report).to_solr) }

    before do
      allow(controller).to receive(:search_result_document).and_return(solr_document)
    end

    it "initializes a presenter" do
      expect(subject).to be_kind_of Hyku::WorkShowPresenter
      expect(subject.manifest_url).to eq "http://test.host/concern/paper_or_reports/#{solr_document.id}/manifest"
    end
  end
end
