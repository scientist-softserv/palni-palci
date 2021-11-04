# frozen_string_literal: true

module Hyku
  class WorkShowPresenter < Hyrax::WorkShowPresenter
    Hyrax::MemberPresenterFactory.file_presenter_class = Hyrax::FileSetPresenter

    delegate :extent, :alternative_title, :additional_information, :rights_notes, :source, :bibliographic_citation, :abstract, to: :solr_document

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
    end

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
