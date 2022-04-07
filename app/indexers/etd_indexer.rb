# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Etd`
class EtdIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('bulkrax_identifier', :facetable)] = object.bulkrax_identifier
      solr_doc['title_ssi'] = SortTitle.new(object.title.first).alphabetical
    end
  end
end
