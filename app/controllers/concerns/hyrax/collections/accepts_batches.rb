# OVERRIDE FILE from Hyrax v2.9.0
#
# Override this class using #class_eval to avoid needing to copy the entire file over from
# the dependency. For more info, see the "Overrides using #class_eval" section in the README.
require_dependency Hyrax::Engine.root.join('app', 'controllers', 'concerns', 'hyrax', 'collections', 'accepts_batches').to_s

Hyrax::Collections::AcceptsBatches.class_eval do
  private

    # OVERRIDE: call #can? on the SolrDocument object instead of its ID to avoid false negatives
    def filter_docs_with_access!(access_type = :edit)
      no_permissions = []
      if batch.empty?
        flash[:notice] = 'Select something first'
      else
        batch.dup.each do |doc_id|
          # OVERRIDE: find SolrDocument and call #can? against it instead of doc_id
          document = ::SolrDocument.find(doc_id)
          unless can?(access_type, document)
            batch.delete(doc_id)
            no_permissions << doc_id
          end
        end
        flash[:notice] = "You do not have permission to edit the documents: #{no_permissions.join(', ')}" unless no_permissions.empty?
      end
    end
end
