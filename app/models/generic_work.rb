# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include IiifPrint.model_configuration(
    pdf_split_child_model: self
  )

  validates :title, presence: { message: 'Your work must have a title.' }

  property :institution,
           predicate: ::RDF::URI.new("http://test.hyku.test/generic_work#institution"),
           multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :types,
           predicate: ::RDF::URI.new("http://test.hyku.test/generic_work#types"),
           multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :format, predicate: ::RDF::Vocab::DC11.format do |index|
    index.as :stored_searchable
  end

  # This must come after the properties because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  self.indexer = GenericWorkIndexer
end
