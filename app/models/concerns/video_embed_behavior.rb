# frozen_string_literal: true

module VideoEmbedBehavior
  extend ActiveSupport::Concern

  included do
    validates :video_embed,
              format: {
                with: /(http:\/\/|https:\/\/)(www\.)?(player\.vimeo\.com|youtube\.com\/embed)/,
                message: "Error: must be a valid YouTube or Vimeo Embed URL."
              },
              if: :video_embed?

    property :video_embed, predicate: ::RDF::URI("https://atla.com/terms/video_embed"), multiple: false do |index|
      index.as :stored_searchable
    end
  end

  def video_embed?
    video_embed.present?
  end
end
