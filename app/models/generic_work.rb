# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include IiifPrint.model_configuration(
    pdf_split_child_model: self
  )

  # rubocop:disable Metrics/LineLength
  property :institution, predicate: ::RDF::URI.new("http://test.hyku.test/generic_work#institution"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end
  # rubocop:enable Metrics/LineLength

  property :types, predicate: ::RDF::Vocab::DC.type, multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :format, predicate: ::RDF::Vocab::DC.format, multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :additional_rights_information, predicate: ::RDF::Vocab::DC.accessRights, multiple: true do |index|
    index.as :stored_searchable
  end

  # This must come after the properties because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  self.indexer = GenericWorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
end
