# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include IiifPrint.model_configuration(
    pdf_split_child_model: self
  )
  # this line needs to be before the validations & properties in order for them to be indexed correctly
  self.indexer = GenericWorkIndexer

  validates :title, presence: { message: 'Your work must have a title.' }
  validates :video_embed,
  format: {
    with: /(http:\/\/|https:\/\/)(www\.)?(player\.vimeo\.com|youtube\.com\/embed)/,
    message: "Error: must be a valid YouTube or Vimeo Embed URL." },
  if: :video_embed?


  property :video_embed, predicate: ::RDF::URI("https://atla.com/terms/video_embed"), multiple: false do |index|
    index.as :stored_searchable
  end

  def video_embed?
    video_embed.present? && !video_embed.blank?
  end

  # This must be included at the end of the file,
  # This line finalizes the metadata schema
  # (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
