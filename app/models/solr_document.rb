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

  attribute :account_cname, Solr::Array, 'account_cname_tesim'
  attribute :additional_rights_info, Solr::Array, 'additional_rights_info_tesim'
  attribute :advisor, Solr::Array, 'advisor_tesim'
  attribute :bibliographic_citation, Solr::Array, 'bibliographic_citation_tesim'
  attribute :committee_member, Solr::Array, 'committee_member_tesim'
  attribute :contributor_institutional_relationship, Solr::Array, 'contributor_institutional_relationship_tesim'
  attribute :contributor_orcid, Solr::String, 'contributor_orcid_tesim'
  attribute :contributor_role, Solr::Array, 'contributor_role_tesim'
  attribute :contributor, Solr::Array, 'contributor_tesim'
  attribute :creator_institutional_relationship, Solr::Array, 'creator_institutional_relationship_tesim'
  attribute :creator_orcid, Solr::String, 'creator_orcid_tesim'
  attribute :date_created, Solr::String, 'date_created_tesim'
  attribute :degree_granting_institution, Solr::Array, 'degree_granting_institution_tesim'
  attribute :degree, Solr::Array, 'degree_tesim'
  attribute :department, Solr::Array, 'department_tesim'
  attribute :discipline, Solr::Array, 'discipline_tesim'
  attribute :event_date, Solr::Array, 'event_date_tesim'
  attribute :event_location, Solr::Array, 'event_location_tesim'
  attribute :event_title, Solr::Array, 'event_title_tesim'
  attribute :extent, Solr::Array, 'extent_tesim'
  attribute :format, Solr::Array, 'format_tesim'
  attribute :funder_awards, Solr::Array, 'funder_awards_tesim'
  attribute :funder_name, Solr::Array, 'funder_name_tesim'
  attribute :identifier, Solr::String, 'identifier_tesim'
  attribute :institution, Solr::String, 'institution_tesim'
  attribute :keyword, Solr::Array, 'keyword_tesim'
  attribute :language, Solr::Array, 'language_tesim'
  # attribute :level, Solr::Array, 'level_tesim'
  attribute :license, Solr::Array, 'license_tesim'
  attribute :location, Solr::Array, 'location_tesim'
  attribute :official_link, Solr::Array, 'official_link_tesim'
  attribute :project_name, Solr::Array, 'project_name_tesim'
  attribute :rendering_ids, Solr::Array, 'hasFormat_ssim'
  attribute :rights_holder, Solr::Array, 'rights_holder_tesim'
  attribute :subject, Solr::Array, 'subject_tesim'
  attribute :types, Solr::Array, 'types_tesim'
  attribute :video_embed, Solr::String, 'video_embed_tesim'
  attribute :year, Solr::String, 'year_tesim'

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
    type: 'types_tesim'
  )

  def show_pdf_viewer
    self['show_pdf_viewer_tesim']
  end

  def show_pdf_download_button
    self['show_pdf_download_button_tesim']
  end
end
