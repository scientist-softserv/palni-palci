# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work PaperOrReport`
class PaperOrReport < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include IiifPrint.model_configuration(
    pdf_split_child_model: self
  )

  self.indexer = PaperOrReportIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :institution, presence: { message: 'Your work must have an institution.' }
  validates :creator, presence: { message: 'Your work must have a creator.' }

  property :institution, predicate: ::RDF::Vocab::ORG.organization, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :format, predicate: ::RDF::Vocab::DC11.format do |index|
    index.as :stored_searchable
  end

  property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder do |index|
    index.as :stored_searchable
  end

  property :creator_orcid, predicate: ::RDF::Vocab::SCHEMA.creator, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :creator_institutional_relationship,
           predicate: ::RDF::URI.intern('https://atla.com/terms/creatorInstitutionalRelationship') do |index|
             index.as :stored_searchable
           end

  property :contributor_orcid,
           predicate: ::RDF::URI('https://atla.com/terms/contributorOrcid'),
           multiple: false do |index|
             index.as :stored_searchable
           end

  property :contributor_institutional_relationship,
           predicate: ::RDF::URI.intern('https://atla.com/terms/contributorInstitutionalRelationship') do |index|
             index.as :stored_searchable
           end

  property :contributor_role, predicate: ::RDF::URI('https://atla.com/terms/contributorRole') do |index|
    index.as :stored_searchable
  end

  property :project_name, predicate: ::RDF::Vocab::BF2.term(:CollectiveTitle) do |index|
    index.as :stored_searchable
  end

  property :funder_name, predicate: ::RDF::Vocab::MARCRelators.fnd do |index|
    index.as :stored_searchable
  end

  property :funder_awards, predicate: ::RDF::Vocab::BF2.awards do |index|
    index.as :stored_searchable
  end

  property :event_title, predicate: ::RDF::Vocab::BF2.term(:Event) do |index|
    index.as :stored_searchable
  end

  property :event_location, predicate: ::RDF::URI('https://atla.com/terms/eventLocation') do |index|
    index.as :stored_searchable
  end

  property :event_date, predicate: ::RDF::URI('https://atla.com/terms/eventDate') do |index|
    index.as :stored_searchable
  end

  property :official_link, predicate: ::RDF::Vocab::SCHEMA.url do |index|
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
