# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include IiifPrint.model_configuration(
    pdf_split_child_model: self
  )
  # this line needs to be before the validations & properties in order for them to be indexed correctly
  self.indexer = GenericWorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []

  validates :title, presence: { message: 'Your work must have a title.' }
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
           predicate: ::RDF::URI.new('http://test.hyku.test/generic_work#institution'),
           multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :format, predicate: ::RDF::Vocab::DC11.format do |index|
    index.as :stored_searchable
  end

  property :additional_rights_info, predicate: ::RDF::URI("https://atla.com/terms/additionalRightsInfo"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :video_embed, predicate: ::RDF::URI("https://atla.com/terms/videoEmbed"), multiple: false do |index|
    index.as :stored_searchable
  end

  # types must be initially defined before the include ::Hyrax::BasicMetadata
  # so that it can be added to the metadata schema
  # and then be overridden below to map to DC.type.
  property :types, predicate: ::RDF::URI.new("https://atla.com/terms/types")

  def video_embed?
    video_embed.present?
  end

  # This must come after the properties because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  # OVERRIDE: Hyrax 3.5.0 to add facet ability
  property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
    index.as :stored_searchable, :facetable
  end

  property :source, predicate: ::RDF::Vocab::DC.source do |index|
    index.as :stored_searchable, :facetable
  end

  property :keyword, predicate: ::RDF::Vocab::SCHEMA.keywords do |index|
    index.as :stored_searchable, :facetable
  end

  property :contributor, predicate: ::RDF::Vocab::DC11.contributor do |index|
    index.as :stored_searchable, :facetable
  end

  property :language, predicate: ::RDF::Vocab::DC11.language do |index|
    index.as :stored_searchable, :facetable
  end

  property :resource_type, predicate: ::RDF::URI.new("https://atla.com/terms/resourceType") do |index|
    index.as :stored_searchable, :facetable
  end

  property :types, predicate: ::RDF::Vocab::DC.type do |index|
    index.as :stored_searchable, :facetable
  end
end
