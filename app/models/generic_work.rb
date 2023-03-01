# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  validates :title, presence: { message: 'Your work must have a title.' }

  property :additional_information, predicate: ::RDF::Vocab::DC.accessRights do |index|
    index.as :stored_searchable
  end

  property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation do |index|
    index.as :stored_searchable
  end

  property :bulkrax_identifier, predicate: ::RDF::URI("https://hykucommons.org/terms/bulkrax_identifier"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  include ::Hyrax::BasicMetadata
  self.indexer = GenericWorkIndexer

  MULTI_VALUED_PROPERTIES = properties.collect do |prop_name, node_config|
    next if %w[head tail].include?(prop_name)
    prop_name.to_sym if node_config.instance_variable_get(:@opts)&.dig(:multiple)
  end.compact.freeze

  prepend OrderAlready.for(*MULTI_VALUED_PROPERTIES)
end
