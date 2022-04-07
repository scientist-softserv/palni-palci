# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  validates :title, presence: { message: 'Your work must have a title.' }

  self.indexer = WorkIndexer

  property :rights_notes, predicate: ::RDF::URI('https://hykucommons.org/terms/rights_notes') do |index|
    index.as :stored_searchable
  end

  property :alternative_title, predicate: ::RDF::Vocab::DC.alternative do |index|
    index.as :stored_searchable
  end

  property :additional_information, predicate: ::RDF::Vocab::DC.accessRights do |index|
    index.as :stored_searchable
  end

  property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation do |index|
    index.as :stored_searchable
  end

  property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
    index.as :stored_searchable
  end

  property :bulkrax_identifier, predicate: ::RDF::URI("https://hykucommons.org/terms/bulkrax_identifier"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  include ::Hyrax::BasicMetadata
end
