# frozen_string_literal: true

class GenericWorkIndexer < AppIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['format_sim'] = object.format.first if object.format.present?
      solr_doc['institution_sim'] = object.institution.first if object.institution.present?
      solr_doc['types_sim'] = object.types.first if object.types.present?
      solr_doc['date_created_sim'] = object.date_created if object.date_created.present?
      solr_doc['resource_type_sim'] = object.resource_type.first if object.resource_type.present?
      solr_doc['contributor_sim'] = object.contributor.first if object.contributor.present?
      solr_doc['keyword_sim'] = object.keyword.first if object.keyword.present?
      solr_doc['language_sim'] = object.language.first if object.language.present?
    end
  end
end
