module Hyku
  class ManifestEnabledWorkShowPresenter < Hyrax::WorkShowPresenter
    Hyrax::MemberPresenterFactory.file_presenter_class = Hyku::FileSetPresenter

    delegate :extent, :rendering_ids, to: :solr_document

    def manifest_url
      manifest_helper.polymorphic_url([:manifest, self])
    end

    # IIIF rendering linking property for inclusion in the manifest
    #
    # @return [Array] array of rendering hashes
    def sequence_rendering
      renderings = []
      if solr_document.rendering_ids.present?
        solr_document.rendering_ids.each do |file_set_id|
          renderings << build_rendering(file_set_id)
        end
      end
      renderings.flatten
    end

    # IIIF metadata for inclusion in the manifest
    #
    # @return [Array] array of metadata hashes
    def manifest_metadata
      metadata = []
      metadata_fields.each do |field|
        metadata << {
          'label' => field.to_s.humanize.capitalize,
          'value' => get_metadata_value(field)
        }
      end
      metadata
    end

    # assumes there can only be one doi
    def doi
      doi_regex = %r{10\.\d{4,9}\/[-._;()\/:A-Z0-9]+}i
      doi = extract_from_identifier(doi_regex)
      doi.join if doi
    end

    # unlike doi, there can be multiple isbns
    def isbns
      isbn_regex = /((?:ISBN[- ]*13|ISBN[- ]*10|)\s*97[89][ -]*\d{1,5}[ -]*\d{1,7}[ -]*\d{1,6}[ -]*\d)|
                    ((?:[0-9][-]*){9}[ -]*[xX])|(^(?:[0-9][-]*){10}$)/x
      isbns = extract_from_identifier(isbn_regex)
      isbns.flatten.compact if isbns
    end

    private

      def extract_from_identifier(rgx)
        if solr_document['identifier_tesim'].present?
          ref = solr_document['identifier_tesim'].map do |str|
            str.scan(rgx)
          end
        end
        ref
      end

      def manifest_helper
        @manifest_helper ||= ManifestHelper.new(request.base_url)
      end

      # Build a rendering hash
      #
      # @return [Hash] rendering
      def build_rendering(file_set_id)
        query_for_rendering(file_set_id).map do |x|
          label = x['label_ssi'] ? ": #{x.fetch('label_ssi')}" : ''
          {
            '@id' => Hyrax::Engine.routes.url_helpers.download_url(x.fetch(ActiveFedora.id_field), host: request.host),
            'format' => x.fetch('mime_type_ssi') ? x.fetch('mime_type_ssi') : 'unknown mime type',
            'label' => 'Download whole resource' + label
          }
        end
      end

      # Query for the properties to create a rendering
      #
      # @return [SolrResult] query result
      def query_for_rendering(file_set_id)
        ActiveFedora::SolrService.query("id:#{file_set_id}",
                                        fl: [ActiveFedora.id_field, 'label_ssi', 'mime_type_ssi'],
                                        rows: 1)
      end

      # Retrieve the required fields from the Form class. Derive the Form class name from the Model name.
      #   The class should exist, but it may not if different namespaces are being used.
      #   If it does not exist, rescue and return an empty Array.
      #
      # @return [Array] required fields
      def metadata_fields
        ns = "Hyrax"
        model = solr_document['has_model_ssim'].first

        "#{ns}::#{model}Form".constantize.required_fields
      rescue StandardError
        []
      end

      # Get the metadata value(s).
      #
      # @return [Array] field value(s)
      def get_metadata_value(field)
        Array.wrap(send(field))
      end
  end
end
