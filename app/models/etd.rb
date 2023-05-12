# frozen_string_literal: true

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
  validates :year, presence: { message: 'Your work must have a four-digit year.' }
  # rubocop:disable Style/RegexpLiteral
  validates :video_embed,
            format: {
              # regex matches only youtube & vimeo urls that are formatted as embed links.
              with: /(http:\/\/|https:\/\/)(www\.)?(player\.vimeo\.com|youtube\.com\/embed)/,
              message: "Error: must be a valid YouTube or Vimeo Embed URL."
            },
            if: :video_embed?
  # rubocop:enable Style/RegexpLiteral

  property :institution,
           predicate: ::RDF::Vocab::ORG.organization,
           multiple: false do |index|
             index.as :stored_searchable, :facetable
           end

  property :format, predicate: ::RDF::Vocab::DC11.format do |index|
    index.as :stored_searchable, :facetable
  end

  property :additional_rights_info, predicate: ::RDF::URI('https://atla.com/terms/additionalRightsInfo') do |index|
    index.as :stored_searchable
  end

  property :degree, predicate: ::RDF::URI('https://atla.com/terms/degree') do |index|
    index.as :stored_searchable, :facetable
  end

  property :level, predicate: ::RDF::URI('https://atla.com/terms/level') do |index|
    index.as :stored_searchable
  end

  property :discipline, predicate: ::RDF::URI('https://atla.com/terms/discipline') do |index|
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

  property :year, predicate: ::RDF::Vocab::DC.date, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :video_embed, predicate: ::RDF::URI("https://atla.com/terms/videoEmbed"), multiple: false do |index|
    index.as :stored_searchable
  end

  def video_embed?
    video_embed.present?
  end

  # types must be initially defined before the include ::Hyrax::BasicMetadata
  # so that it can be added to the metadata schema
  # and then be overridden below to map to DC.type.
  property :types, predicate: ::RDF::URI.new("https://atla.com/terms/types")

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  property :resource_type, predicate: ::RDF::URI.new("https://atla.com/terms/resourceType") do |index|
    index.as :stored_searchable, :facetable
  end

  property :types, predicate: ::RDF::Vocab::DC.type do |index|
    index.as :stored_searchable, :facetable
  end
end
