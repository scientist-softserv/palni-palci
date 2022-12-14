# frozen_string_literal: true

# OVERRIDE: Hyrax 3.4.1 here to add featured collection methods and to delegate collection presenters to the member presenter factory

module Hyku
  class WorkShowPresenter < Hyrax::WorkShowPresenter
    Hyrax::MemberPresenterFactory.file_presenter_class = Hyrax::FileSetPresenter

    delegate :title_or_label, :extent, :additional_information, :source, :bibliographic_citation, to: :solr_document

    # OVERRIDE Hyrax v2.9.0 here to make featured collections work
    delegate :collection_presenters, to: :member_presenter_factory

    # assumes there can only be one doi
    def doi
      doi_regex = %r{10\.\d{4,9}\/[-._;()\/:A-Z0-9]+}i
      doi = extract_from_identifier(doi_regex)
      doi&.join
    end

    # unlike doi, there can be multiple isbns
    def isbns
      isbn_regex = /((?:ISBN[- ]*13|ISBN[- ]*10|)\s*97[89][ -]*\d{1,5}[ -]*\d{1,7}[ -]*\d{1,6}[ -]*\d)|
                    ((?:[0-9][-]*){9}[ -]*[xX])|(^(?:[0-9][-]*){10}$)/x
      isbns = extract_from_identifier(isbn_regex)
      isbns&.flatten&.compact
    end

    # OVERRIDE FILE from Hyrax v2.9.0
    # @return [Array] list to display with Kaminari pagination
    # paginating on members so we can filter out derived status
    Hyrax::WorkShowPresenter.class_eval do
      def list_of_item_ids_to_display
        paginated_item_list(page_array: members)
      end

      def page_title
        if human_readable_type == "Generic Work"
          "#{title.first} | ID: #{id} | #{I18n.t('hyrax.product_name')}"
        else
          "#{human_readable_type} | #{title.first} | ID: #{id} | #{I18n.t('hyrax.product_name')}"
        end 
      end
    end

    # OVERRIDE here for featured collection methods
    # Begin Featured Collections Methods
    def collection_featurable?
      user_can_feature_collection? && solr_document.public?
    end

    def display_feature_collection_link?
      collection_featurable? && FeaturedCollection.can_create_another? && !collection_featured?
    end

    def display_unfeature_collection_link?
      collection_featurable? && collection_featured?
    end

    def collection_featured?
      # only look this up if it's not boolean; ||= won't work here
      if @collection_featured.nil?
        @collection_featured = FeaturedCollection.where(collection_id: solr_document.id).exists?
      end
      @collection_featured
    end

    def user_can_feature_collection?
      current_ability.can?(:create, FeaturedCollection)
    end
    # End Featured Collections Methods

    private

      def extract_from_identifier(rgx)
        if solr_document['identifier_tesim'].present?
          ref = solr_document['identifier_tesim'].map do |str|
            str.scan(rgx)
          end
        end
        ref
      end

      # OVERRIDE FILE from Hyrax v2.9.0
      # Gets the member id's for pagination, filter out derived files
      Hyrax::WorkShowPresenter.class_eval do
        def members
          members = member_presenters_for(authorized_item_ids)
          filtered_members =
            if current_ability.admin?
              members
            else
              members.reject { |m| m.solr_document['is_derived_ssi'] == 'true' }
            end
          filtered_members.collect(&:id)
        end
      end
  end
end
