# frozen_string_literal: true

class AppIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc["account_cname_tesim"] = Site.instance&.account&.cname
      add_subject(solr_doc)
    end
  end

  private

  def format_subject
    if object.subject.present?
      object.subject.map do |subject|
        no_periods_or_spaces = subject.strip.chomp('.')
        no_periods_or_spaces.slice(0, 1).capitalize + no_periods_or_spaces.slice(1..-1)
      end
    end
  end

  # parses the subject to contain normalized capitalization
  def add_subject(solr_doc)
    solr_doc['subject_tesim'] = format_subject
    solr_doc['subject_sim'] = format_subject
  end
end
