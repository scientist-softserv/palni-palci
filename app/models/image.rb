# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
class Image < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  property :extent, predicate: ::RDF::Vocab::DC.extent, multiple: true do |index|
    index.as :stored_searchable
  end

  property :additional_information, predicate: ::RDF::Vocab::DC.accessRights do |index|
    index.as :stored_searchable
  end

  property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation do |index|
    index.as :stored_searchable
  end
  
  property :bulkrax_identifier, predicate: ::RDF::URI("https://hykucommons.org/terms/bulkrax_identifier"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :admin_note, predicate: ::RDF::Vocab::SCHEMA.positiveNotes, multiple: false do |index|
    index.as :stored_searchable
  end

  # This must come after the properties because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  self.indexer = ImageIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
end
