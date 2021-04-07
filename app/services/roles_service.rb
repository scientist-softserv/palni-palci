# frozen_string_literal: true
# TODO(bkiahstroud): filename and location make sense?
module RolesService
  ADMIN_ROLE = ['admin']

  TENANT_ROLES = [
    'tenant_manager',
    'tenant_editor',
    'tenant_reader'
  ].freeze

  USER_ROLES = [
    'user_admin',
    'user_manager',
    'user_reader'
  ].freeze

  COLLECTION_ROLES = [
    'collection_manager',
    'collection_editor',
    'collection_reader'
  ].freeze

  ALL_DEFAULT_ROLES = ADMIN_ROLE + TENANT_ROLES + USER_ROLES + COLLECTION_ROLES

  class << self
    def create_default_roles!
      # NOTE: stop Roles from being created in public schema
      return '`AccountElevator.switch!` into an Account before creating default Roles' if Site.instance.is_a?(NilSite)

      ALL_DEFAULT_ROLES.each do |role_name|
        Role.find_or_create_by!(
          name: role_name,
          resource_id: Site.instance.id,
          resource_type: 'Site'
        )
      end
    end
  end
end
