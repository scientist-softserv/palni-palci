# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::Hyrax::BasicMetadata
  include IiifPrint.model_configuration(
    pdf_split_child_model: self
  )

  validates :title, presence: { message: 'Your work must have a title.' }

  # ("https://iro.bl.uk/resource#bulkraxIdentifier")
  property :institution, predicate: ::RDF::URI.new("http://hyku.test/institutions"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :types, predicate: ::RDF::Vocab::DC.type, multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :format, predicate: ::RDF::Vocab::DC.format, multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  self.indexer = GenericWorkIndexer
end
