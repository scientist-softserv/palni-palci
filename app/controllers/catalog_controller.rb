# frozen_string_literal: true

class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller
  include BlacklightRangeLimit::ControllerOverride
  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior
  include BlacklightOaiProvider::Controller
  before_action :sort_alphabetical
  # These before_action filters apply the hydra access controls
  before_action :enforce_show_permissions, only: :show

  def sort_alphabetical
    params[:sort] = 'title_ssi asc' if params[:f].present?
  end

  def self.uploaded_field
    'system_create_dtsi'
  end

  def self.modified_field
    'system_modified_dtsi'
  end

  # CatalogController-scope behavior and configuration for BlacklightIiifSearch
  include BlacklightIiifSearch::Controller

  configure_blacklight do |config|
    # TODO: Replace with Hyrax.config.solr_default_method when upgrading to >= Hyrax v4.0.0
    config.http_method = :post

    # IiifPrint index fields
    config.add_index_field 'all_text_tsimv', highlight: true, helper_method: :render_ocr_snippets

    # configuration for Blacklight IIIF Content Search
    config.iiif_search = {
      full_text_field: 'all_text_tsimv',
      object_relation_field: 'is_page_of_ssim',
      supported_params: %w[q page],
      autocomplete_handler: 'iiif_suggest',
      suggester_name: 'iiifSuggester'
    }

    config.view.gallery.partials = %i[index_header index]
    config.view.masonry.partials = [:index]
    config.view.slideshow.partials = [:index]

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'dismax'
    config.advanced_search[:form_solr_parameters] ||= {}
    config.advanced_search[:form_facet_partial] ||= "advanced_search_facets_as_select"

    # Use locally customized AdvSearchBuilder so we can enable blacklight_advanced_search
    config.search_builder_class = AdvSearchBuilder

    # Show gallery view
    config.view.gallery.partials = %i[index_header index]
    config.view.slideshow.partials = [:index]

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: "search",
      rows: 10,
      qf: "admin_note_tesim title_tesim alternative_title_tesim description_tesim creator_tesim contributor_tesim related_url_tesim learning_resource_type_tesim education_level_tesim audience_tesim degree_name_tesim degree_discipline_tesim degree_grantor_tesim date_tesim table_of_contents_tesim rights_statement_tesim license_tesim rights_holder_tesim additional_information_tesim oer_size_tesim publisher_tesim identifier_tesim keyword_tesim subject_tesim language_tesim resource_type_tesim date_created_tesim date_uploaded_tesim date_modified_tesim accessibility_feature_tesim accessibility_hazard_tesim accessibility_summary_tesim format_tesim extent_tesim all_text_timv",
      "hl": true,
      "hl.simple.pre": "<span class='highlight'>",
      "hl.simple.post": "</span>",
      "hl.snippets": 30,
      "hl.fragsize": 100
    }

    # Specify which field to use in the tag cloud on the homepage.
    # To disable the tag cloud, comment out this line.
    config.tag_cloud_field_name = 'tag_sim'

    # solr field configuration for document/show views
    config.index.title_field = 'title_tesim'
    config.index.display_type_field = 'has_model_ssim'
    config.index.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    config.add_facet_field 'human_readable_type_sim', label: "Type", limit: 5
    config.add_facet_field 'resource_type_sim', label: "Resource Type", limit: 5
    config.add_facet_field 'creator_sim', limit: 5
    config.add_facet_field 'contributor_sim', label: "Contributor", limit: 5
    config.add_facet_field 'keyword_sim', limit: 5
    config.add_facet_field 'subject_sim', limit: 5
    config.add_facet_field 'language_sim', limit: 5
    config.add_facet_field 'based_near_label_sim', limit: 5
    config.add_facet_field 'publisher_sim', limit: 5
    config.add_facet_field 'file_format_sim', limit: 5
    config.add_facet_field 'contributing_library_sim', limit: 5
    config.add_facet_field 'date_ssi', label: 'Date Created', range: { num_segments: 10, assumed_boundaries: [1100, Time.zone.now.year + 2], segments: false, slider_js: false, maxlength: 4 }
    config.add_facet_field 'member_of_collections_ssim', limit: 5, label: 'Collections'
    config.add_facet_field 'account_institution_name_ssim', label: 'Institution', limit: 5

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name', if: false
    config.add_index_field solr_name("creator", :stored_searchable), itemprop: 'creator', link_to_search: solr_name("creator", :facetable)
    config.add_index_field solr_name("date", :stored_searchable), itemprop: 'date'
    config.add_index_field solr_name('collection_subtitle', :stored_searchable), label: "Collection Subtitle"
    config.add_index_field solr_name("description", :stored_searchable), itemprop: 'description', helper_method: :truncate_and_iconify_auto_link
    config.add_index_field solr_name("resource_type", :stored_searchable), label: "Resource Type", link_to_search: solr_name("resource_type", :facetable)
    config.add_index_field solr_name('learning_resource_type', :stored_searchable), label: "Learning resource type"
    config.add_index_field solr_name('education_level', :stored_searchable), label: "Education level"
    config.add_index_field solr_name('audience', :stored_searchable), label: "Audience"
    config.add_index_field solr_name('discipline', :stored_searchable), label: "Discipline"
    # config.add_index_field solr_name("keyword", :stored_searchable), itemprop: 'keywords', link_to_search: solr_name("keyword", :facetable)
    # config.add_index_field solr_name("subject", :stored_searchable), itemprop: 'about', link_to_search: solr_name("subject", :facetable)
    # config.add_index_field solr_name("contributor", :stored_searchable), itemprop: 'contributor', link_to_search: solr_name("contributor", :facetable)
    # config.add_index_field solr_name("proxy_depositor", :symbol), label: "Depositor", helper_method: :link_to_profile
    # config.add_index_field solr_name("depositor"), label: "Owner", helper_method: :link_to_profile
    # config.add_index_field solr_name("publisher", :stored_searchable), itemprop: 'publisher', link_to_search: solr_name("publisher", :facetable)
    # config.add_index_field solr_name("based_near_label", :stored_searchable), itemprop: 'contentLocation', link_to_search: solr_name("based_near_label", :facetable)
    # config.add_index_field solr_name("language", :stored_searchable), itemprop: 'inLanguage', link_to_search: solr_name("language", :facetable)
    # config.add_index_field solr_name("date_uploaded", :stored_sortable, type: :date), itemprop: 'datePublished', helper_method: :human_readable_date
    # config.add_index_field solr_name("date_modified", :stored_sortable, type: :date), itemprop: 'dateModified', helper_method: :human_readable_date
    # config.add_index_field solr_name("date_created", :stored_searchable), itemprop: 'dateCreated'
    # config.add_index_field solr_name("rights_statement", :stored_searchable), label: "Rights statement", helper_method: :rights_statement_links
    # config.add_index_field solr_name("license", :stored_searchable), label: 'License', helper_method: :license_links
    # config.add_index_field solr_name("file_format", :stored_searchable), link_to_search: solr_name("file_format", :facetable)
    # config.add_index_field solr_name("identifier", :stored_searchable), helper_method: :index_field_link, field_name: 'identifier'
    # config.add_index_field solr_name("embargo_release_date", :stored_sortable, type: :date), label: "Embargo release date", helper_method: :human_readable_date
    # config.add_index_field solr_name("lease_expiration_date", :stored_sortable, type: :date), label: "Lease expiration date", helper_method: :human_readable_date
    # config.add_index_field solr_name("alternative_title", :stored_searchable), label: "Alternative title"
    # config.add_index_field solr_name("table_of_contents", :stored_searchable), label: "Table of contents"
    # config.add_index_field solr_name("additional_information", :stored_searchable), label: "Additional information"
    # config.add_index_field solr_name("rights_holder", :stored_searchable), label: "Rights holder"
    # config.add_index_field solr_name("oer_size", :stored_searchable), label: "Size"
    # config.add_index_field solr_name('accessibility_feature', :stored_searchable), label: "Accessibility feature", link_to_search: solr_name("accessibility_feature", :facetable)
    # config.add_index_field solr_name('accessibility_hazard', :stored_searchable), label: "Accessibility hazard", link_to_search: solr_name("accessibility_hazard", :facetable)
    # config.add_index_field solr_name('accessibility_summary', :stored_searchable), label: "Accessibility Summary", link_to_search: solr_name("accessibility_summary", :facetable)

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field solr_name("title", :stored_searchable)
    config.add_show_field solr_name('admin_note', :stored_searchable), label: "Administrative Notes"
    config.add_show_field solr_name("alternative_title", :stored_searchable), label: "Alternative title"
    config.add_show_field solr_name("creator", :stored_searchable)
    config.add_show_field solr_name("contributor", :stored_searchable)
    config.add_show_field solr_name("related_url", :stored_searchable)
    config.add_show_field solr_name('learning_resource_type', :stored_searchable)
    config.add_show_field solr_name('education_level', :stored_searchable)
    config.add_show_field solr_name('audience', :stored_searchable)
    config.add_show_field solr_name('discipline', :stored_searchable)
    config.add_show_field solr_name("date", :stored_searchable), label: "Date", helper_method: :human_readable_date
    config.add_show_field solr_name("description", :stored_searchable)
    config.add_show_field solr_name("table_of_contents", :stored_searchable), label: "Table of contents"
    config.add_show_field solr_name("subject", :stored_searchable)
    config.add_show_field solr_name("rights_statement", :stored_searchable)
    config.add_show_field solr_name("license", :stored_searchable)
    config.add_show_field solr_name("rights_holder", :stored_searchable), label: "Rights holder"
    config.add_show_field solr_name("additional_information", :stored_searchable), label: "Additional information"
    config.add_show_field solr_name("language", :stored_searchable)
    config.add_show_field solr_name("oer_size", :stored_searchable), label: "Size"
    config.add_show_field solr_name("publisher", :stored_searchable)
    config.add_show_field solr_name("identifier", :stored_searchable)
    config.add_show_field solr_name("resource_type", :stored_searchable), label: "Resource Type"
    config.add_show_field solr_name('accessibility_feature', :stored_searchable)
    config.add_show_field solr_name('accessibility_hazard', :stored_searchable)
    config.add_show_field solr_name('accessibility_summary', :stored_searchable), label: "Accessibility summary"
    config.add_show_field solr_name("keyword", :stored_searchable)
    config.add_show_field solr_name("based_near_label", :stored_searchable)
    config.add_show_field solr_name("date_uploaded", :stored_searchable)
    config.add_show_field solr_name("date_modified", :stored_searchable)
    config.add_show_field solr_name("date_created", :stored_searchable)
    config.add_show_field solr_name("format", :stored_searchable)
    config.add_show_field solr_name('extent', :stored_searchable)
    config.add_show_field solr_name('previous_version_id', :stored_searchable)
    config.add_show_field solr_name('newer_version_id', :stored_searchable)
    config.add_show_field solr_name('related_item_id', :stored_searchable)
    config.add_show_field solr_name('contributing_library', :stored_searchable)
    config.add_show_field solr_name('library_catalog_identifier', :stored_searchable)
    config.add_show_field solr_name('chronology_note', :stored_searchable)

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    #
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('all_fields', label: 'All Fields', include_in_advanced_search: false, advanced_parse: false) do |field|
      all_names = config.show_fields.values.map(&:field).join(" ")
      title_name = 'title_tesim'
      field.solr_parameters = {
        qf: "#{all_names} file_format_tesim all_text_timv",
        pf: title_name.to_s
      }
    end

    # list of all the search_fields that will use the default configuration below.
    search_fields_without_customization = [
      { name: 'title', label: 'Title' },
      { name: 'creator', label: 'Creator' },
      { name: 'date_created', label: 'Date or Date Created' },
      { name: 'keyword', label: 'Keyword' },
      { name: 'license', label: 'License' },
      { name: 'subject', label: 'Subject' },
      { name: 'abstract', label: 'Abstract' },
      { name: 'advisor', label: 'Advisor' },
      { name: 'accessibility_feature', label: 'Accessibility Feature' },
      { name: 'accessibility_hazard', label: 'Accessibility Hazard' },
      { name: 'accessibility_summary', label: 'Accessibility Summary' },
      { name: 'additional_information', label: 'Additional Rights Information or Access Rights' },
      { name: 'alternative_title', label: 'Alternative Title' },
      { name: 'audience', label: 'Audience' },
      { name: 'bibliographic_citation', label: 'Bibliographic Citation' },
      { name: 'committee_member', label: 'Committee Member' },
      { name: 'contributor', label: 'Contributor' },
      { name: 'department', label: 'Department' },
      { name: 'depositor', label: 'Depositor' },
      { name: 'description', label: 'Description' },
      { name: 'degree_discipline', label: 'Discipline' },
      { name: 'education_level', label: 'Education Level' },
      { name: 'extent', label: 'Extent' },
      { name: 'degree_grantor', label: 'Grantor' },
      { name: 'identifier', label: 'Identifier' },
      { name: 'language', label: 'Language' },
      { name: 'learning_resource_type', label: 'Learning Resource Type' },
      { name: 'degree_level', label: 'Level' },
      { name: 'publisher', label: 'Publisher' },
      { name: 'related_url', label: 'Related URL' },
      { name: 'rights_holder', label: 'Rights Holder' },
      { name: 'rights_notes', label: 'Rights Notes' },
      { name: 'rights_statement', label: 'Rights or Rights Statement' },
      { name: 'size', label: 'Size' },
      { name: 'source', label: 'Source' },
      { name: 'table_of_contents', label: 'Table of Contents' },
      { name: 'resource_type', label: 'Type or Resource Type' }
    ]

    search_fields_without_customization.each do |search_field|
      config.add_search_field(search_field[:name]) do |field|
        field.label = search_field[:label]
        field.solr_parameters = { "spellcheck.dictionary": search_field[:name] }
        solr_name = "#{search_field[:name]}_tesim"
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end
    end

    # If there is something additional about a search field that needs to be customized i.e. whether to include in advanced search, or if it needs a different solr name, add it below
    config.add_search_field('date') do |field|
      solr_name = 'date_ssi'
      field.include_in_advanced_search = false
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('based_near_label') do |field|
      solr_name = 'based_near_label_tesim'
      field.include_in_advanced_search = false
      field.label = 'Location'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    # format cannot be included in advanced search because an error is thrown in Blacklight when formats do not match specific mime types
    # see https://github.com/projectblacklight/blacklight/blob/13a8122fc6495e52acabc33875b80b51613d8351/app/controllers/concerns/blacklight/catalog.rb#L167
    # and the error on https://github.com/projectblacklight/blacklight/blob/13a8122fc6495e52acabc33875b80b51613d8351/app/controllers/concerns/blacklight/catalog.rb#L206
    config.add_search_field('format') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        "spellcheck.dictionary": "format"
      }
      solr_name = 'format_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field "score desc, #{uploaded_field} desc", label: "relevance"
    config.add_sort_field "title_ssi asc", label: "title (A-Z)"
    config.add_sort_field "title_ssi desc", label: "title (Z-A)"
    config.add_sort_field "date_ssi desc", label: "date created \u25BC"
    config.add_sort_field "date_ssi asc", label: "date created \u25B2"
    config.add_sort_field "#{uploaded_field} desc", label: "date uploaded \u25BC"
    config.add_sort_field "#{uploaded_field} asc", label: "date uploaded \u25B2"

    # OAI Config fields
    config.oai = {
      provider: {
        repository_name: ->(controller) { controller.send(:current_account)&.name.presence },
        # repository_url:  ->(controller) { controller.oai_catalog_url },
        record_prefix: ->(controller) { controller.send(:current_account).oai_prefix },
        admin_email:   ->(controller) { controller.send(:current_account).oai_admin_email },
        sample_id:     ->(controller) { controller.send(:current_account).oai_sample_identifier }
      },
      document: {
        limit: 100, # number of records returned with each request, default: 15
        set_fields: [ # ability to define ListSets, optional, default: nil
          { label: 'collection', solr_field: 'isPartOf_ssim' }
        ]
      }
    }

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

  # This is overridden just to give us a JSON response for debugging.
  def show
    _, @document = fetch params[:id]
    render json: @document.to_h
  end
end
