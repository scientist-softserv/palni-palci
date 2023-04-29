# frozen_string_literal: true

class GenericWorkIndexer < AppIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['format_sim'] = object.format.first if object.format.present?
      solr_doc['institution_sim'] = object.institution.first if object.institution.present?
      solr_doc['types_sim'] = object.types.first if object.types.present?
      solr_doc['additional_rights_information_sim'] = object.types.first if object.types.present?
    end
  end
end
