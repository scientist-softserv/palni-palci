module RDF
  class CustomShowViewerTerm < Vocabulary('http://id.loc.gov/vocabulary/identifiers/')
    property 'show_viewer'
  end
end

module PdfViewerBehavior
  extend ActiveSupport::Concern

  included do
    property :show_viewer, predicate: RDF::CustomShowViewerTerm.show_viewer, multiple: false do |index|
      index.as :stored_searchable
    end

    after_initialize :set_default_show_viewer
  end

  private

    # This is here so that the checkbox is checked by default
    def set_default_show_viewer
      self.show_viewer ||= '1'
    end
end
