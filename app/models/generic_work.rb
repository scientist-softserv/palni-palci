# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  validates :title, presence: { message: 'Your work must have a title.' }

  self.indexer = WorkIndexer

  property :rights_notes, predicate: ::RDF::URI('https://hykucommons.org/terms/rights_notes') do |index|
    index.as :stored_searchable
  end

  self.human_readable_type = 'Work'
  include ::Hyrax::BasicMetadata
end
