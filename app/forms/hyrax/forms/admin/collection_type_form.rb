# OVERRIDE FILE from Hryax v2.9.0
require_dependency Hyrax::Engine.root.join('app', 'forms', 'hyrax', 'forms', 'admin', 'collection_type_form').to_s

Hyrax::Forms::Admin::CollectionTypeForm.class_eval do
  # OVERRIDE: Add new method to filter out collection_type_participants for Collection Types in the UI. We
  # do this because collection_type_participants for Collection Types should never be allowed to be removed.
  def filter_access_grants_by_collection_type(access)
    filtered_access_grants = self.collection_type_participants.select(&access)
    filtered_access_grants.reject! { |ag| ::RolesService::COLLECTION_ROLES.include?(ag.agent_id) }

    filtered_access_grants || []
  end
end
