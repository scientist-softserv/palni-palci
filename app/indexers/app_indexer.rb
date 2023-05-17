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
      add_format(solr_doc)
    end
  end

  private

  # parses the subject to contain normalized capitalization
  def parse_subject
    # rubocop:disable Style/GuardClause
    if object.subject.present?
      object.subject.map do |subject|
        no_periods_or_spaces = subject.strip.chomp('.')
        no_periods_or_spaces.slice(0, 1).capitalize + no_periods_or_spaces.slice(1..-1)
      end
    end
    # rubocop:enable Style/GuardClause
  end

  # parses the format to save the correct labels
  def parse_format
    if object.format.present?
      object.format.map do |format|
        Hyrax::FormatService.label_from_alt(format.to_s.strip)
      end
    end
  end

  # adds parsed format to solr document
  def add_format(solr_doc)
    solr_doc['format_tesim'] = parse_format
    solr_doc['format_sim'] = parse_format
  end

  # adds parsed subject to solr document
  def add_subject(solr_doc)
    solr_doc['subject_tesim'] = parse_subject
    solr_doc['subject_sim'] = parse_subject
  end
end
