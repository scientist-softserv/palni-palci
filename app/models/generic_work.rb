# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include IiifPrint.model_configuration(
    pdf_split_child_model: self
  )

  self.indexer = GenericWorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []

  validates :title, presence: { message: 'Your work must have a title.' }

  property :institution,
           predicate: ::RDF::URI.new('http://test.hyku.test/generic_work#institution'),
           multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :format, predicate: ::RDF::Vocab::DC11.format do |index|
    index.as :stored_searchable
  end

  # This must come after the properties because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  # OVERRIDE: Hyrax 3.5.0 to add facet ability
  property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
    index.as :stored_searchable, :facetable
  end

  property :source, predicate: ::RDF::Vocab::DC.source do |index|
    index.as :stored_searchable, :facetable
  end

  property :keyword, predicate: ::RDF::Vocab::SCHEMA.keywords do |index|
    index.as :stored_searchable, :facetable
  end

  property :contributor, predicate: ::RDF::Vocab::DC11.contributor do |index|
    index.as :stored_searchable, :facetable
  end

  property :language, predicate: ::RDF::Vocab::DC11.language do |index|
    index.as :stored_searchable, :facetable
  end

  property :resource_type, predicate: ::RDF::Vocab::DC.type do |index|
    index.as :stored_searchable, :facetable
  end
end
