# frozen_string_literal: true

module Hyrax
  class CollectionThumbnailPathService < Hyrax::ThumbnailPathService
    class << self
      def default_image
        ActionController::Base.helpers.image_path 'llama.png'
      end
    end
  end
end