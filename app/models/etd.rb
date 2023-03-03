# Generated via
#  `rails generate hyrax:work Etd`
class Etd < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = EtdIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :advisor, predicate: ::RDF::URI('https://hykucommons.org/terms/advisor') do |index|
    index.as :stored_searchable
  end

  property :bulkrax_identifier, predicate: ::RDF::URI("https://hykucommons.org/terms/bulkrax_identifier"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :committee_member, predicate: ::RDF::URI('https://hykucommons.org/terms/committee_member') do |index|
    index.as :stored_searchable
  end

  property :degree_discipline, predicate: ::RDF::URI('https://hykucommons.org/terms/degree_discipline') do |index|
    index.as :stored_searchable
  end

  property :degree_grantor, predicate: ::RDF::URI('https://hykucommons.org/terms/degree_grantor') do |index|
    index.as :stored_searchable
  end

  property :degree_level, predicate: ::RDF::URI('https://hykucommons.org/terms/degree_level') do |index|
    index.as :stored_searchable
  end

  property :degree_name, predicate: ::RDF::URI('https://hykucommons.org/terms/degree_name') do |index|
    index.as :stored_searchable
  end

  property :department, predicate: ::RDF::URI('https://hykucommons.org/terms/department') do |index|
    index.as :stored_searchable
  end

  property :format, predicate: ::RDF::Vocab::DC.format do |index|
    index.as :stored_searchable
  end

  property :additional_information, predicate: ::RDF::Vocab::DC.accessRights do |index|
    index.as :stored_searchable
  end

  property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation do |index|
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
  # This line must be kept below all others that set up properties,
  # including `include ::Hyrax::BasicMetadata`. All properties must
  # be declared before their values can be ordered.
  include OrderMetadataValues
end
