# frozen_string_literal: true

class GenericWorkIndexer < AppIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      add_format(solr_doc)
      add_institution(solr_doc)
      add_types(solr_doc)
      add_date_created(solr_doc)
      add_resource_type(solr_doc)
      add_contributor(solr_doc)
      add_keyword(solr_doc)
      add_language(solr_doc)
    end
  end

  private

  def add_format(solr_doc)
    solr_doc['format_sim'] = object.format.first if object.format.present?
  end

  def add_institution(solr_doc)
    solr_doc['institution_sim'] = object.institution.first if object.institution.present?
  end

  def add_types(solr_doc)
    solr_doc['types_sim'] = object.types.first if object.types.present?
  end

  def add_date_created(solr_doc)
    solr_doc['date_created_sim'] = object.date_created if object.date_created.present?
  end

  def add_resource_type(solr_doc)
    solr_doc['resource_type_sim'] = object.resource_type.first if object.resource_type.present?
  end

  def add_contributor(solr_doc)
    solr_doc['contributor_sim'] = object.contributor.first if object.contributor.present?
  end

  def add_keyword(solr_doc)
    solr_doc['keyword_sim'] = object.keyword.first if object.keyword.present?
  end

  def add_language(solr_doc)
    solr_doc['language_sim'] = object.language.first if object.language.present?
  end
end
