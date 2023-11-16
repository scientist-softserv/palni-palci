# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Etd`
class Etd < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include IiifPrint.model_configuration(
    pdf_split_child_model: GenericWork
  )
  include PdfBehavior

  self.indexer = EtdIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :creator, presence: { message: 'Your work must have a creator.' }
  validates :abstract, presence: { message: 'Your work must have an abstract.' }
  validates :degree, presence: { message: 'Your work must have a degree.' }
  # validates :level, presence: { message: 'Your work must have a level.' }
  # validates :discipline, presence: { message: 'Your work must have a discipline.' }
  validates :degree_granting_institution, presence: { message: 'Your work must have a degree granting institution.' }
  # rubocop:disable Style/RegexpLiteral
  validates :year,
            presence: {
              message: 'Your work must have a four-digit year.'
            },
            format: {
              # regex matches only youtube & vimeo urls that are formatted as embed links.
              with: /\A(19|20)\d{2}\z/,
              message: "Error: must be a valid four digit year."
            }
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

  # property :level, predicate: ::RDF::URI('https://atla.com/terms/level') do |index|
  #  index.as :stored_searchable
  # end

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

  # types must be initially defined before the include ::Hyrax::BasicMetadata
  # so that it can be added to the metadata schema
  # and then be overridden below to map to DC.type.
  property :types, predicate: ::RDF::URI.new("https://atla.com/terms/types")

  # this is the unique identifier bulkrax uses for import.
  # this property only needs to be added to the model so it can be saved for works.
  # it will not show in the public view for users, and cannot be entered manually via the edit work form.
  property :source_identifier, predicate: ::RDF::URI.new("https://atla.com/terms/sourceIdentifier"), multiple: false

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
