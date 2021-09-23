# frozen_string_literal: true

class SolrDocument
  include Blacklight::Solr::Document
  include BlacklightOaiProvider::SolrDocument

  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.
  use_extension(Hydra::ContentNegotiation)

  attribute :extent, Solr::Array, solr_name('extent')
  attribute :rendering_ids, Solr::Array, solr_name('hasFormat', :symbol)
  attribute :alternative_title, Solr::String, solr_name('alternative_title')
  attribute :audience, Solr::Array, solr_name('audience')
  attribute :education_level, Solr::Array, solr_name('education_level')
  attribute :learning_resource_type, Solr::Array, solr_name('learning_resource_type')
  attribute :table_of_contents, Solr::String, solr_name('table_of_contents')
  attribute :additional_information, Solr::String, solr_name('additional_information')
  attribute :rights_holder, Solr::String, solr_name('rights_holder')
  attribute :rights_notes, Solr::String, solr_name('rights_notes')
  attribute :oer_size, Solr::String, solr_name('oer_size')
  attribute :accessibility_summary, Solr::String, solr_name('accessibility_summary')
  attribute :accessibility_feature, Solr::Array, solr_name('accessibility_feature')
  attribute :accessibility_hazard, Solr::Array, solr_name('accessibility_hazard')
  attribute :previous_version_id, Solr::String, solr_name('previous_version_id')
  attribute :newer_version_id, Solr::String, solr_name('newer_version_id')
  attribute :alternate_version_id, Solr::String, solr_name('alternate_version_id')
  attribute :related_item_id, Solr::String, solr_name('related_item_id')
  attribute :discipline, Solr::Array, solr_name('discipline')
  attribute :advisor, Solr::Array, solr_name('advisor')
  attribute :committee_member, Solr::Array, solr_name('committee_member')
  attribute :degree_discipline, Solr::Array, solr_name('degree_discipline')
  attribute :degree_grantor, Solr::Array, solr_name('degree_grantor')
  attribute :degree_level, Solr::Array, solr_name('degree_level')
  attribute :degree_name, Solr::Array, solr_name('degree_name')
  attribute :department, Solr::Array, solr_name('department')
  attribute :format, Solr::Array, solr_name('format')
  attribute :title_ssi, Solr::Array, solr_name('title_ssi')

  field_semantics.merge!(
    contributor: 'contributor_tesim',
    creator: 'creator_tesim',
    date: 'date_created_tesim',
    description: 'description_tesim',
    identifier: 'identifier_tesim',
    language: 'language_tesim',
    publisher: 'publisher_tesim',
    relation: 'nesting_collection__pathnames_ssim',
    rights: 'rights_statement_tesim',
    subject: 'subject_tesim',
    title: 'title_tesim',
    type: 'human_readable_type_tesim'
  )

end
