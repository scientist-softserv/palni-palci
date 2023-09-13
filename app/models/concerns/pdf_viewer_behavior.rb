module RDF
  class CustomShowViewerTerm < Vocabulary('http://id.loc.gov/vocabulary/identifiers/')
    property 'show_viewer'
  end

  class CustomShowDownloadButtonTerm < Vocabulary('http://id.loc.gov/vocabulary/identifiers/')
    property 'show_download_button'
  end
end

module PdfViewerBehavior
  extend ActiveSupport::Concern

  included do
    property :show_viewer, predicate: RDF::CustomShowViewerTerm.show_viewer, multiple: false do |index|
      index.as :stored_searchable
    end

    property :show_download_button, predicate: RDF::CustomShowDownloadButtonTerm.show_download_button, multiple: false do |index|
      index.as :stored_searchable
    end

    after_initialize :set_default_show_viewer, :set_default_show_download_button
  end

  private

    # This is here so that the checkbox is checked by default
    def set_default_show_viewer
      self.show_viewer ||= '1'
    end

    def set_default_show_download_button
      self.show_download_button ||= '1'
    end
end
