class IIIFThumbnailPathService < Hyrax::WorkThumbnailPathService
  class << self
    protected

      # @param [FileSet] file_set
      # @return the IIIF url for the thumbnail.
      def thumbnail_path(file_set, size = '300,'.freeze)
        file = file_set.original_file
        return unless file
        Riiif::Engine.routes.url_helpers.image_path(
          file.id,
          size: size
        )
      end

      def thumbnail?(_thumbnail)
        true
      end
  end
end
