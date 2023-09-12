module RDF
  class CustomShowViewerTerm < Vocabulary('http://id.loc.gov/vocabulary/identifiers/')
    property 'show_viewer'
  end
end

module ShowViewerFlag
  extend ActiveSupport::Concern

  included do
    property :show_viewer, predicate: RDF::CustomShowViewerTerm.show_viewer, multiple: false do |index|
      index.as :stored_searchable
    end
  end
end