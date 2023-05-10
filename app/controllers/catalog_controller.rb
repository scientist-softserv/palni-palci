# frozen_string_literal: true

class CatalogController < ApplicationController
  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior
  include BlacklightOaiProvider::Controller

  # These before_action filters apply the hydra access controls
  before_action :enforce_show_permissions, only: :show

  def self.uploaded_field
    'system_create_dtsi'
  end

  def self.modified_field
    'system_modified_dtsi'
  end

  # CatalogController-scope behavior and configuration for BlacklightIiifSearch
  include BlacklightIiifSearch::Controller

  configure_blacklight do |config|
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

    config.search_builder_class = IiifPrint::CatalogSearchBuilder

    # Show gallery view
    config.view.gallery.partials = %i[index_header index]
    config.view.slideshow.partials = [:index]

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: "search",
      rows: 10,
      qf: "title_tesim description_tesim creator_tesim keyword_tesim all_text_timv"
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
    config.add_facet_field 'resource_type_sim', label: 'Resource Type', limit: 5
    config.add_facet_field 'creator_sim', limit: 5
    config.add_facet_field 'contributor_sim', label: 'Contributor', limit: 5
    config.add_facet_field 'keyword_sim', limit: 5, label: 'Keyword'
    config.add_facet_field 'subject_sim', limit: 5, label: 'Subject'
    config.add_facet_field 'language_sim', limit: 5, label: 'Language'
    config.add_facet_field 'publisher_sim', limit: 5, label: 'Publisher'
    config.add_facet_field 'date_created_sim', limit: 5, label: 'Date Created'
    config.add_facet_field 'types_sim', limit: 5, label: 'Types'
    config.add_facet_field 'year_sim', limit: 5, label: 'Year'
    config.add_facet_field 'institution_sim', limit: 5, label: 'Institution'
    config.add_facet_field 'format_sim', limit: 5, label: 'Format'
    config.add_facet_field 'member_of_collections_ssim', limit: 5, label: 'Collections'
    config.add_facet_field 'degree_sim', limit: 5, label: 'Degree'
    config.add_facet_field 'discipline_sim', limit: 5, label: 'Discipline'
    config.add_facet_field 'degree_granting_institution_sim', limit: 5, label: 'Degree Granting Institution'
    config.add_facet_field 'funder_name_sim', limit: 5, label: 'Funder Name'
    config.add_facet_field 'event_title_sim', limit: 5, label: 'Event Title'
    config.add_facet_field 'event_date_sim', limit: 5, label: 'Event Date'
    # config.add_facet_field 'based_near_label_sim', limit: 5

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'title_tesim', label: 'Title', itemprop: 'name', if: false
    config.add_index_field 'description_tesim', itemprop: 'description', helper_method: :index_filter
    config.add_index_field 'creator_tesim', itemprop: 'creator', link_to_search: 'creator_sim'
    config.add_index_field 'resource_type_tesim', label: 'Resource Type', link_to_search: 'resource_type_sim'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'title_tesim', label: 'Title'
    config.add_show_field 'creator_tesim'
    config.add_show_field 'keyword_tesim'
    config.add_show_field 'rights_statement_tesim', label: 'Rights Statement'
    config.add_show_field 'license_tesim'
    config.add_show_field 'alternative_title_tesim', label: 'Alternative Title'
    config.add_show_field 'contributor_tesim', label: 'Contribute'
    config.add_show_field 'description_tesim'
    config.add_show_field 'abstract_tesim'
    config.add_show_field 'access_right_tesim', label: 'Access rights'
    config.add_show_field 'rights_notes_tesim', label: 'Rights notes'
    config.add_show_field 'publisher_tesim'
    config.add_show_field 'date_created_tesim', label: 'Date created'
    config.add_show_field 'year_tesim', label: 'Year'
    config.add_show_field 'subject_tesim'
    config.add_show_field 'language_tesim'
    config.add_show_field 'identifier_tesim', label: 'Identifier'
    config.add_show_field 'related_url_tesim', label: 'Related URL'
    config.add_show_field 'source_tesim'
    config.add_show_field 'based_near_label_tesim'
    config.add_show_field 'date_uploaded_tesim'
    config.add_show_field 'date_modified_tesim'
    config.add_show_field 'resource_type_tesim', label: 'Resource Type'
    config.add_show_field 'types_tesim', label: 'Type'
    config.add_show_field 'additional_rights_info_tesim', label: 'Additional rights info'
    config.add_show_field 'bibliographic_citation_tesim', label: 'Bibliographic citation'
    config.add_show_field 'format_tesim', label: 'Format'
    config.add_show_field 'extent_tesim'
    config.add_show_field 'institution_tesim', label: 'Institution'
    config.add_show_field 'rights_holder_tesim', label: 'Rights holder'
    config.add_show_field 'creator_orcid_tesim', label: 'Creator ORCID'
    config.add_show_field 'creator_institutional_relationship_tesim', label: 'Creator institutional relationship'
    config.add_show_field 'contributor_orcid_tesim', label: 'Contributor ORCID'
    config.add_show_field 'contributor_institutional_relationship_tesim', label: 'Contributor institutional relationship'
    config.add_show_field 'contributor_role_tesim', label: 'Contributor role'
    config.add_show_field 'project_name_tesim', label: 'Project name'
    config.add_show_field 'funder_name_tesim', label: 'Funder'
    config.add_show_field 'funder_awards_tesim', label: 'Funder awards'
    config.add_show_field 'event_title_tesim', label: 'Event title'
    config.add_show_field 'event_location_tesim', label: 'Event location'
    config.add_show_field 'event_date_tesim', label: 'Event date'
    config.add_show_field 'official_link_tesim', label: 'Official URL'
    config.add_show_field 'degree_tesim', label: 'Degree'
    config.add_show_field 'level_tesim', label: 'Level'
    config.add_show_field 'discipline_tesim', label: 'Discipline'
    config.add_show_field 'degree_graning_institution_tesim', label: 'Degree Granting Institution'
    config.add_show_field 'advisor_tesim', label: 'Advisor'
    config.add_show_field 'committee_member_tesim', label: 'Committee member'
    config.add_show_field 'department_tesim', label: 'Department'

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
    config.add_search_field('all_fields', label: 'All Fields', include_in_advanced_search: false) do |field|
      all_names = config.show_fields.values.map(&:field).join(" ")
      title_name = 'title_tesim'
      field.solr_parameters = {
        qf: "#{all_names} file_format_tesim all_text_timv",
        pf: title_name.to_s
      }
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.
    # creator, title, description, publisher, date_created,
    # subject, language, resource_type, format, identifier, based_near,
    config.add_search_field('contributor') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = { "spellcheck.dictionary": "contributor" }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      solr_name = 'contributor_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('creator') do |field|
      field.solr_parameters = { "spellcheck.dictionary": "creator" }
      solr_name = 'creator_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('title') do |field|
      field.solr_parameters = {
        "spellcheck.dictionary": "title"
      }
      solr_name = 'title_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('description') do |field|
      field.label = "Abstract or Summary"
      field.solr_parameters = {
        "spellcheck.dictionary": "description"
      }
      solr_name = 'description_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('publisher') do |field|
      field.solr_parameters = {
        "spellcheck.dictionary": "publisher"
      }
      solr_name = 'publisher_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('date_created') do |field|
      field.solr_parameters = {
        "spellcheck.dictionary": "date_created"
      }
      solr_name = 'created_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('subject') do |field|
      field.solr_parameters = {
        "spellcheck.dictionary": "subject"
      }
      solr_name = 'subject_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('language') do |field|
      field.solr_parameters = {
        "spellcheck.dictionary": "language"
      }
      solr_name = 'language_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('resource_type') do |field|
      field.solr_parameters = {
        "spellcheck.dictionary": "resource_type"
      }
      solr_name = 'resource_type_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

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

    config.add_search_field('identifier') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        "spellcheck.dictionary": "identifier"
      }
      solr_name = 'id_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('based_near_label') do |field|
      field.label = "Location"
      field.solr_parameters = {
        "spellcheck.dictionary": "based_near_label"
      }
      solr_name = 'based_near_label_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('keyword') do |field|
      field.solr_parameters = {
        "spellcheck.dictionary": "keyword"
      }
      solr_name = 'keyword_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('depositor') do |field|
      solr_name = 'depositor_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('rights_statement') do |field|
      solr_name = 'rights_statement_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('license') do |field|
      solr_name = 'license_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('extent') do |field|
      solr_name = 'extent_tesim'
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
    config.add_sort_field "#{uploaded_field} desc", label: "date uploaded \u25BC"
    config.add_sort_field "#{uploaded_field} asc", label: "date uploaded \u25B2"
    config.add_sort_field "#{modified_field} desc", label: "date modified \u25BC"
    config.add_sort_field "#{modified_field} asc", label: "date modified \u25B2"

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
