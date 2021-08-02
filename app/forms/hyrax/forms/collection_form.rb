# OVERRIDE FILE from Hryax v2.9.0
require_dependency Hyrax::Engine.root.join('app', 'forms', 'hyrax', 'forms', 'collection_form').to_s

Hyrax::Forms::CollectionForm.class_eval do
  # OVERRIDE: Add new method to filter out access_grants for Collection Roles (collection_manager,
  # collection_editor, and collection_reader) in the UI. We do this because access_grants for
  # Collection Roles should never be allowed to be removed.
  def filter_access_grants_by_access(access)
    filtered_access_grants = self.permission_template.access_grants.select(&access)
    filtered_access_grants.reject! { |ag| ::RolesService::COLLECTION_ROLES.include?(ag.agent_id) }

    filtered_access_grants || []
  end
end
