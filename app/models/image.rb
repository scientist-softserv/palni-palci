# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
class Image < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include IiifPrint.model_configuration(
    pdf_split_child_model: self
  )
  include PdfBehavior

  validates :title, presence: { message: 'Your work must have a title.' }
  validates :creator, presence: { message: 'Your work must have a creator.' }
  validates :abstract, presence: { message: 'Your work must have an abstract.' }
  # rubocop:disable Style/RegexpLiteral
  validates :video_embed,
            format: {
              # regex matches only youtube & vimeo urls that are formatted as embed links.
              with: /(http:\/\/|https:\/\/)(www\.)?(player\.vimeo\.com|youtube\.com\/embed)/,
              message: "Error: must be a valid YouTube or Vimeo Embed URL."
            },
            if: :video_embed?
  # rubocop:enable Style/RegexpLiteral

  def video_embed?
    video_embed.present?
  end

  property :source_identifier, predicate: ::RDF::URI.new("https://atla.com/terms/sourceIdentifier"), multiple: false

  property :extent, predicate: ::RDF::Vocab::DC.extent, multiple: true do |index|
    index.as :stored_searchable
  end

  property :additional_rights_info,
           predicate: ::RDF::URI("https://atla.com/terms/additionalRightsInfo"),
           multiple: true do |index|
    index.as :stored_searchable
  end

  property :institution,
           predicate: ::RDF::Vocab::ORG.organization,
           multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  # types must be initially defined before the include ::Hyrax::BasicMetadata
  # so that it can be added to the metadata schema
  # and then be overridden below to map to DC.type.
  property :types, predicate: ::RDF::URI.new("https://atla.com/terms/types")

  property :format, predicate: ::RDF::Vocab::DC11.format do |index|
    index.as :stored_searchable, :facetable
  end

  property :video_embed, predicate: ::RDF::URI("https://atla.com/terms/videoEmbed"), multiple: false do |index|
    index.as :stored_searchable
  end

  # This must come after the properties because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  property :resource_type, predicate: ::RDF::URI.new("https://atla.com/terms/resourceType") do |index|
    index.as :stored_searchable, :facetable
  end

  property :types, predicate: ::RDF::Vocab::DC.type do |index|
    index.as :stored_searchable, :facetable
  end

  self.indexer = ImageIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
end
