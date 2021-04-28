# frozen_string_literal: true
# TODO(bkiahstroud): filename and location make sense?
class RolesService
  ADMIN_ROLE = %w[admin]

  TENANT_ROLES = %w[
    tenant_manager
    tenant_editor
    tenant_reader
  ].freeze

  USER_ROLES = %w[
    user_admin
    user_manager
    user_reader
  ].freeze

  COLLECTION_ROLES = %w[
    collection_manager
    collection_editor
    collection_reader
  ].freeze

  ALL_DEFAULT_ROLES = ADMIN_ROLE + TENANT_ROLES + USER_ROLES + COLLECTION_ROLES

  class << self
    def find_or_create_site_role!(role_name:)
      Role.find_or_create_by!(
        name: role_name,
        resource_id: Site.instance.id,
        resource_type: 'Site'
      )
    end

    def create_default_roles!
      # Stop Roles from being created in public schema
      return '`AccountElevator.switch!` into an Account before creating default Roles' if Site.instance.is_a?(NilSite)

      ALL_DEFAULT_ROLES.each do |role_name|
        find_or_create_site_role!(role_name: role_name)
      end
    end

    # Because each collection role has some level of access to every Collection within a tenant,
    # creating a Hyrax::PermissionTemplateAccess record (combined with Ability#user_groups)
    # means all Collections will show up in Blacklight / Solr queries.
    def create_collection_accesses!
      Collection.find_each do |c|
        pt = Hyrax::PermissionTemplate.find_or_create_by!(source_id: c.id)
        original_access_grants_count = pt.access_grants.count

        pt.access_grants.find_or_create_by!(
          access: Hyrax::PermissionTemplateAccess::MANAGE,
          agent_type: Hyrax::PermissionTemplateAccess::GROUP,
          agent_id: 'collection_manager'
        )

        pt.access_grants.find_or_create_by!(
          access: Hyrax::PermissionTemplateAccess::VIEW,
          agent_type: Hyrax::PermissionTemplateAccess::GROUP,
          agent_id: 'collection_editor'
        )

        pt.access_grants.find_or_create_by!(
          access: Hyrax::PermissionTemplateAccess::VIEW,
          agent_type: Hyrax::PermissionTemplateAccess::GROUP,
          agent_id: 'collection_reader'
        )

        c.reset_access_controls! if pt.access_grants.count != original_access_grants_count
      end
    end

    # Because some of the collection roles have access to every Collection within a tenant, create a
    # Hyrax::CollectionTypeParticipant record for them on every Hyrax::CollectionType (except the AdminSet)
    def create_collection_type_participants!
      Hyrax::CollectionType.find_each do |ct|
        next if ct.admin_set?

        # The :collection_manager role will automatically get a Hyrax::PermissionTemplateAccess
        # record when a Collection is created, giving them manage access to that Collection.
        ct.collection_type_participants.find_or_create_by!(
          access: Hyrax::CollectionTypeParticipant::MANAGE_ACCESS,
          agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE,
          agent_id: 'collection_manager'
        )

        # The :collection_editor role will automatically get a Hyrax::PermissionTemplateAccess
        # record when a Collection is created, giving them create access to that Collection.
        ct.collection_type_participants.find_or_create_by!(
          access: Hyrax::CollectionTypeParticipant::CREATE_ACCESS,
          agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE,
          agent_id: 'collection_editor'
        )
      end
    end

    # Because the collection roles are used to explicitly grant Collection creation permissions,
    # provide a way to easily remove that access from all registered users. Participants can
    # still be added / removed on an individual Hyrax::CollectionType basis.
    #
    # NOTE: This is not technically necessary for collection roles to function properly. However,
    # without it, collection readers will be allowed to create Collections whose Hyrax::CollectionType
    # has this Hyrax::CollectionTypeParticipant.
    def destroy_registered_group_collection_type_participants!
      Hyrax::CollectionTypeParticipant.where(agent_type: 'group', agent_id: ::Ability.registered_group_name, access: 'create').map(&:destroy)
    end

    def seed_superadmin!
      return 'Seed data should not be used in the production environment' if Rails.env.production? || Rails.env.staging?

      user = User.where(email: 'admin@example.com').first_or_initialize do |u|
        if u.new_record?
          u.password = 'testing123'
          u.display_name = 'Admin'
          u.save!
        end
        u
      end

      unless user.has_role?('superadmin')
        user.roles << Role.find_or_create_by!(name: 'superadmin')
      end

      Account.find_each do |account|
        AccountElevator.switch!(account.cname)

        user.add_default_group_memberships!
      end

      user
    end

    def seed_qa_users!
      return 'Seed data should not be used in the production environment' if Rails.env.production? || Rails.env.staging?

      ActiveRecord::Base.transaction do
        ALL_DEFAULT_ROLES.each do |role_name|
          user = User.where(email: "#{role_name}@example.com").first_or_initialize do |u|
            if u.new_record?
              u.password = 'testing123'
              u.display_name = role_name.titleize
              u.save!
            end
            u
          end

          Account.find_each do |account|
            AccountElevator.switch!(account.cname)

            unless user.has_role?(role_name, Site.instance)
              user.add_default_group_memberships!
              user.roles << find_or_create_site_role!(role_name: role_name)
            end
          end

          puts "Email: #{user.email}\nRoles: #{user.roles.map(&:name)}\n\n"; nil
        end
      end
    end
  end
end
