# frozen_string_literal: true

module Hyrax
  module ManifestBuilderServiceDecorator
    private

      ##
      # @return [Hash<Array>] the Hash to be used by "label" to change `&amp;`	to `&`
      # @see #loof
      def sanitize_value(text)
        return loof(text) unless text.is_a?(Hash)
        text[text.keys.first] = text.values.flatten.map { |value| loof(value) }
        text
      end

      ##
      # @return [String] the String that gets unescaped since Loofah is too aggressive for example
      #   it changes to `&` to `&amp;` which will be displayed in the Universal Viewer and manifest
      # @see #sanitize_value
      def loof(text)
        CGI.unescapeHTML(Loofah.fragment(text.to_s).scrub!(:prune).to_s)
      end

      # rubocop:disable Lint/ShadowedArgument
      def sanitize_v3(hash:, presenter:, solr_doc_hits:)
        hash = super
        hash['viewingHint'] = 'paged'
        hash
      end
    # rubocop:enable Lint/ShadowedArgument
  end
end

Hyrax::ManifestBuilderService.prepend(Hyrax::ManifestBuilderServiceDecorator)
