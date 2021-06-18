# OVERRIDE FILE from Hyrax 2.5.1
module Hyrax
  module Ability
    module SolrDocumentAbility
      def solr_document_abilities
        if admin?
          can [:manage], ::SolrDocument
        else
          # OVERRIDE: remove :destroy -- only users with manage access can destroy
          can [:edit, :update], ::SolrDocument do |solr_doc|
            test_edit(solr_doc.id)
          end
          can :read, ::SolrDocument do |solr_doc|
            test_read(solr_doc.id)
          end
        end
      end
    end
  end
end
