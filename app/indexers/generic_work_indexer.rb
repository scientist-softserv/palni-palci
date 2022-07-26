# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work GenericWork`
class GenericWorkIndexer < AppIndexer
  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('bulkrax_identifier', :facetable)] = object.bulkrax_identifier
      solr_doc['title_ssi'] = SortTitle.new(object.title.first).alphabetical
    end
  end
end
