# Generated via
#  `rails generate hyrax:work Oer`
class Oer < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = OerIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :audience, presence: { message: 'You must select an audience.' }
  validates :education_level, presence: { message: 'You must select an education level.' }
  validates :learning_resource_type, presence: { message: 'You must select a learning resource type.' }
  validates :resource_type, presence: { message: 'You must select a resource type.' }
  validates :discipline, presence: { message: 'You must select a discipline.' }

  property :audience, predicate: ::RDF::Vocab::SCHEMA.EducationalAudience do |index|
    index.as :stored_searchable, :facetable
  end

  property :education_level, predicate: ::RDF::Vocab::DC.educationLevel do |index|
    index.as :stored_searchable, :facetable
  end

  property :learning_resource_type, predicate: ::RDF::Vocab::SCHEMA.learningResourceType do |index|
    index.as :stored_searchable, :facetable
  end

  property :alternative_title, predicate: ::RDF::Vocab::DC.alternative do |index|
    index.as :stored_searchable
  end

  property :date, predicate: ::RDF::Vocab::DC.date do |index|
    index.as :stored_searchable
  end

  property :table_of_contents, predicate: ::RDF::Vocab::DC.tableOfContents do |index|
    index.as :stored_searchable
  end

  property :additional_information, predicate: ::RDF::Vocab::DC.accessRights do |index|
    index.as :stored_searchable
  end

  property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder do |index|
    index.as :stored_searchable
  end

  property :oer_size, predicate: ::RDF::Vocab::DC.extent do |index|
    index.as :stored_searchable
  end

  # TODO: clicking on link in show pg fails to produce expected search results
  property :accessibility_feature, predicate: ::RDF::Vocab::SCHEMA.accessibilityFeature, multiple: true do |index|
    index.as :stored_searchable
  end

  # TODO: clicking on link in show pg fails to produce expected search results
  property :accessibility_hazard, predicate: ::RDF::Vocab::SCHEMA.accessibilityHazard, multiple: true do |index|
    index.as :stored_searchable
  end

  property :accessibility_summary, predicate: ::RDF::Vocab::SCHEMA.accessibilitySummary, multiple: false do |index|
    index.as :stored_searchable
  end

  property :discipline, predicate: ::RDF::Vocab::DC.coverage do |index|
    index.as :stored_searchable, :facetable
  end

  self.human_readable_type = 'OER'
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
