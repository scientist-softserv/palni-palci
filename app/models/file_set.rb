# frozen_string_literal: true

# Generated by hyrax:models:install
class FileSet < ActiveFedora::Base
  property :is_derived,
            predicate: ::RDF::URI.intern('https://hykucommons.org/terms/isDerived'),
            multiple: false do |index|
              index.as :stored_searchable
            end
  property :bulkrax_identifier, predicate: ::RDF::URI("https://hykucommons.org/terms/bulkrax_identifier"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end
  include ::Hyrax::FileSetBehavior
end
