# OVERRIDE FILE from Hyrax v2.9.0
#
# Override this class using #class_eval to avoid needing to copy the entire file over from
# the dependency. For more info, see the "Overrides using #class_eval" section in the README.
require_dependency Hyrax::Engine.root.join('app', 'services', 'hyrax', 'collections', 'permissions_create_service').to_s

Hyrax::Collections::PermissionsCreateService.class_eval do
  # @api private
  #
  # Gather the default permissions needed for a new collection
  #
  # @param collection_type [CollectionType] the collection type of the new collection
  # @param creating_user [User] the user that created the collection
  # @param grants [Array<Hash>] additional grants to apply to the new collection
  # @return [Hash] a hash containing permission attributes
  #
  # OVERRIDE: add collection roles with default access
  def self.access_grants_attributes(collection_type:, creating_user:, grants:)
    [
      { agent_type: 'group', agent_id: admin_group_name, access: Hyrax::PermissionTemplateAccess::MANAGE }
    ].tap do |attribute_list|
      # Grant manage access to the creating_user if it exists
      attribute_list << { agent_type: 'user', agent_id: creating_user.user_key, access: Hyrax::PermissionTemplateAccess::MANAGE } if creating_user
      # OVERRIDE: add :collection_editor and :collection_reader roles as default collection viewers
      attribute_list << { agent_type: 'group', agent_id: 'collection_editor', access: Hyrax::PermissionTemplateAccess::VIEW }
      attribute_list << { agent_type: 'group', agent_id: 'collection_reader', access: Hyrax::PermissionTemplateAccess::VIEW }
    end + managers_of_collection_type(collection_type: collection_type) + grants
  end
  private_class_method :access_grants_attributes
end
