# frozen_string_literal: true
module Hyrax
  # This search builder requires that a accessor named "collection" exists in the scope
  class CollectionMemberSearchBuilder < ::Hyrax::CollectionSearchBuilder
    include Hyrax::FilterByType
    attr_writer :collection, :search_includes_models

    class_attribute :collection_membership_field
    self.collection_membership_field = 'member_of_collection_ids_ssim'

    # Defines which search_params_logic should be used when searching for Collection members
    self.default_processor_chain += [:member_of_collection, :show_works_or_works_that_contain_files]

    # @param [Object] scope Typically the controller object
    # @param [Symbol] search_includes_models +:works+ or +:collections+; (anything else retrieves both)
    def initialize(*args,
                   scope: nil,
                   collection: nil,
                   search_includes_models: nil)
      @collection = collection
      @search_includes_models = search_includes_models
      Rails.logger.info("COLLECTION_MEMBER_SEARCH_BUILDER INITIALIZED")
      if args.any?
        super(*args)
      else
        super(scope)
      end
    end

    def collection
      @collection || (scope.context[:collection] if scope&.respond_to?(:context))
    end

    def search_includes_models
      Rails.logger.info("SEARCH INCLUDES MODELS METHOD")
      @search_includes_models || :works
    end

    # include filters into the query to only include the collection memebers
    def member_of_collection(solr_parameters)
      Rails.logger.info("*****************************************************")
      Rails.logger.info("MEMBER_OF_COLLECTIONS METHOD")
      Rails.logger.info("*****************************************************")
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "#{collection_membership_field}:#{collection.id}"
      # solr_parameters[:fq] << "search_field:all_fields"
    end

    # This overrides the models in FilterByType
    def models
      work_classes + collection_classes
    end

    private

    def only_works?
      search_includes_models == :works
    end

    def only_collections?
      search_includes_models == :collections
    end

    # BEGIN OVERRIDE METHODS - MOVE TO MODULE TO INCLUDE?
    # BEGIN OVERRIDE METHODS - MOVE TO MODULE TO INCLUDE?
    def show_works_or_works_that_contain_files(solr_parameters)
      Rails.logger.info("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
      Rails.logger.info("SHOW_WORKS_OR_WORKS_THAT_CONTAIN_FILES METHOD")
      Rails.logger.info("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
      return if blacklight_params[:q].blank?
      solr_parameters[:user_query] = blacklight_params[:q]
      solr_parameters[:q] = new_query
      solr_parameters[:defType] = 'lucene'
    end

    # the {!lucene} gives us the OR syntax
    def new_query
      Rails.logger.info("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
      Rails.logger.info("NEW_QUERY METHOD")
      Rails.logger.info("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
      "{!lucene}#{interal_query(dismax_query)} #{interal_query(join_for_works_from_files)}"
    end

    # the _query_ allows for another parser (aka dismax)
    def interal_query(query_value)
      Rails.logger.info("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
      Rails.logger.info("INTERNAL_QUERY METHOD")
      Rails.logger.info("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
      "_query_:\"#{query_value}\""
    end

    # the {!dismax} causes the query to go against the query fields
    def dismax_query
      Rails.logger.info("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
      Rails.logger.info("DISMAX_QUERY METHOD")
      Rails.logger.info("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
      "{!dismax v=$user_query}"
    end

    # join from file id to work relationship solrized file_set_ids_ssim
    def join_for_works_from_files
      Rails.logger.info("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
      Rails.logger.info("JOIN_FOR_WORKS_FROM_FILES METHOD")
      Rails.logger.info("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
      "{!join from=#{Hyrax.config.id_field} to=file_set_ids_ssim}#{dismax_query}"
    end
  end
end
