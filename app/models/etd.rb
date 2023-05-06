# Generated via
#  `rails generate hyrax:work Etd`
class Etd < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = EtdIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :creator, presence: { message: 'Your work must have a creator.' }
  validates :degree, presence: { message: 'Your work must have a degree.' }
  validates :level, presence: { message: 'Your work must have a level.' }
  validates :discipline, presence: { message: 'Your work must have a discipline.' }
  validates :degree_granting_institution, presence: { message: 'Your work must have a degree granting institution.' }

  property :institution, predicate: ::RDF::Vocab::ORG.organization, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :format, predicate: ::RDF::Vocab::DC11.format do |index|
    index.as :stored_searchable, :facetable
  end

  property :degree, predicate: ::RDF::URI('https://atla.com/terms/degree') do |index|
    index.as :stored_searchable, :facetable
  end

  property :level, predicate: ::RDF::URI('https://atla.com/terms/level') do |index|
    index.as :stored_searchable
  end

  property :discipline, predicate: ::RDF::URI('https://atla.com/terms/degree') do |index|
    index.as :stored_searchable, :facetable
  end

  property :degree_granting_institution,
           predicate: ::RDF::URI('https://atla.com/terms/degreeGrantingInstitution') do |index|
             index.as :stored_searchable, :facetable
           end

  property :advisor, predicate: ::RDF::URI('https://atla.com/terms/advisor') do |index|
    index.as :stored_searchable
  end

  property :committee_member, predicate: ::RDF::URI('https://atla.com/terms/committeeMember') do |index|
    index.as :stored_searchable
  end

  property :department, predicate: ::RDF::URI('https://atla.com/terms/department') do |index|
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
