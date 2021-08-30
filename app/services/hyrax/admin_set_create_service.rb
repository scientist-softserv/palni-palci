# Override from hyrax 2.5.1 to migrate Hyku::Group into Hyrax::Group
module Hyrax
  # Responsible for creating an AdminSet and its corresponding data:
  #
  # * An associated permission template
  # * Available workflows
  # * An active workflow
  #
  # @see AdminSet
  # @see Hyrax::PermissionTemplate
  # @see Sipity::Workflow
  class AdminSetCreateService
    # @api public
    # Creates the default AdminSet and corresponding data
    # @param admin_set_id [String] The default admin set ID
    # @param title [Array<String>] The title of the default admin set
    # @return [TrueClass]
    # @see AdminSet
    def self.create_default_admin_set(admin_set_id:, title:)
      admin_set = AdminSet.new(id: admin_set_id, title: Array.wrap(title))
      begin
        new(admin_set: admin_set, creating_user: nil).create
      rescue ActiveFedora::IllegalOperation
        # It is possible that another thread created the AdminSet just before this method
        # was called, so ActiveFedora will raise IllegalOperation. In this case we can safely
        # ignore the error.
        Rails.logger.error("AdminSet ID=#{AdminSet::DEFAULT_ID} may or may not have been created due to threading issues.")
      end
    end

    # @api public
    # Creates a non-default AdminSet and corresponding data
    # @param admin_set [AdminSet] the admin set to operate on
    # @param creating_user [User] the user who created the admin set
    # @return [TrueClass, FalseClass] true if it was successful
    # @see AdminSet
    # @raise [RuntimeError] if you attempt to create a default admin set via this mechanism
    def self.call(admin_set:, creating_user:, **kwargs)
      raise "Use .create_default_admin_set to create a default admin set" if admin_set.default_set?
      new(admin_set: admin_set, creating_user: creating_user, **kwargs).create
    end

    # @param admin_set [AdminSet] the admin set to operate on
    # @param creating_user [User] the user who created the admin set (if any).
    # @param workflow_importer [#call] imports the workflow
    def initialize(admin_set:, creating_user:, workflow_importer: default_workflow_importer)
      @admin_set = admin_set
      @creating_user = creating_user
      @workflow_importer = workflow_importer
    end

    attr_reader :creating_user, :admin_set, :workflow_importer

    # Creates an admin set, setting the creator and the default access controls.
    # @return [TrueClass, FalseClass] true if it was successful
    def create
      admin_set.creator = [creating_user.user_key] if creating_user
      admin_set.save.tap do |result|
        if result
          ActiveRecord::Base.transaction do
            permission_template = create_permission_template
            workflow = create_workflows_for(permission_template: permission_template)
            create_default_access_for(permission_template: permission_template, workflow: workflow) if admin_set.default_set?
          end
        end
      end
    end

    private

      def access_grants_attributes
        [
          { agent_type: 'group', agent_id: admin_group_name, access: Hyrax::PermissionTemplateAccess::MANAGE }
        ].tap do |attribute_list|
          # Grant manage access to the creating_user if it exists. Should exist for all but default Admin Set
          attribute_list << { agent_type: 'user', agent_id: creating_user.user_key, access: Hyrax::PermissionTemplateAccess::MANAGE } if creating_user
          # OVERRIDE: grant DEPOSIT access to :work_depositor and :work_editor roles, as well as VIEW access to the :work_editor role
          attribute_list << { agent_type: 'group', agent_id: 'work_depositor', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
          attribute_list << { agent_type: 'group', agent_id: 'work_editor', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
          attribute_list << { agent_type: 'group', agent_id: 'work_editor', access: Hyrax::PermissionTemplateAccess::VIEW }
        end
      end

      def admin_group_name
        ::Ability.admin_group_name
      end

      def create_permission_template
        permission_template = PermissionTemplate.create!(source_id: admin_set.id, access_grants_attributes: access_grants_attributes)
        admin_set.reset_access_controls!
        permission_template
      end

      def create_workflows_for(permission_template:)
        workflow_importer.call(permission_template: permission_template)
        # This code must be invoked before calling `Sipity::Role.all` or the managing, approving, and depositing roles won't be there
        register_default_sipity_roles!

        grant_all_workflow_roles_to_creating_user_and_admins!(permission_template: permission_template)
        # OVERRIDE: add default Sipity roles to editors and depositors
        grant_workflow_roles_to_editors!(permission_template: permission_template)
        grant_workflow_roles_to_depositors!(permission_template: permission_template)

        Sipity::Workflow.activate!(permission_template: permission_template, workflow_name: Hyrax.config.default_active_workflow_name)
      end

      # OVERRIDE: register all roles, not just MANAGING
      # Force creation of registered roles if they don't exist
      def register_default_sipity_roles!
        Sipity::Role[Hyrax::RoleRegistry::MANAGING]
        Sipity::Role[Hyrax::RoleRegistry::APPROVING]
        Sipity::Role[Hyrax::RoleRegistry::DEPOSITING]
      end

      # Grant all workflow roles to the creating_user and the admin group.
      # OVERRIDE: Extract logic that updates the data into #grant_workflow_roles!
      # so it can be reused.
      def grant_all_workflow_roles_to_creating_user_and_admins!(permission_template:)
        workflow_agents = [Hyrax::Group.find_by!(name: admin_group_name)] # The admin group should always receive workflow roles
        workflow_agents |= Hyrax::Group.select { |g| g.has_site_role?(:admin) }
        workflow_agents << creating_user if creating_user # The default admin set does not have a creating user

        grant_workflow_roles!(permission_template: permission_template, workflow_agents: workflow_agents, role_filters: nil)
      end

      # OVERRIDE: Add new method to grant APPROVING and DEPOSITING Sipity roles to
      # "Editors" (Users and Hyrax::Groups who have the :work_editor Rolify role).
      def grant_workflow_roles_to_editors!(permission_template:)
        editor_sipity_roles = [Hyrax::RoleRegistry::APPROVING, Hyrax::RoleRegistry::DEPOSITING]
        workflow_agents = Hyrax::Group.select { |g| g.has_site_role?(:work_editor) }.tap do |agent_list|
          ::User.find_each do |u|
            agent_list << u if u.has_role?(:work_editor, Site.instance)
          end
        end

        grant_workflow_roles!(permission_template: permission_template, workflow_agents: workflow_agents, role_filters: editor_sipity_roles)
      end

      # OVERRIDE: Add new method to grant DEPOSITING Sipity role to
      # "Depositors" (Users and Hyrax::Groups who have the :work_depositor Rolify role).
      def grant_workflow_roles_to_depositors!(permission_template:)
        depositor_sipity_role = [Hyrax::RoleRegistry::DEPOSITING]
        workflow_agents = Hyrax::Group.select { |g| g.has_site_role?(:work_depositor) }.tap do |agent_list|
          ::User.find_each do |u|
            agent_list << u if u.has_role?(:work_depositor, Site.instance)
          end
        end

        grant_workflow_roles!(permission_template: permission_template, workflow_agents: workflow_agents, role_filters: depositor_sipity_role)
      end

      # OVERRIDE: Add new method to grant workflow roles to Users and Hyrax::Groups. This is modified
      # logic extracted from the original #grant_all_workflow_roles_to_creating_user_and_admins method.
      def grant_workflow_roles!(permission_template:, workflow_agents:, role_filters:)
        role_set = if role_filters.present?
                     Sipity::Role.select { |role| role_filters.include?(role.name) }
                   else
                     Sipity::Role.all
                   end

        permission_template.available_workflows.each do |workflow|
          role_set.each do |role|
            # OVERRIDE: Call the PermissionGenerator directly. Before, we were using
            # Sipity::Workflow#update_responsibilities, which removes any workflow_agents
            # not passed to it. Because we're building permissions across multiple
            # methods now, appending is preferred over resetting.
            Hyrax::Workflow::PermissionGenerator.call(roles: role,
                                                      workflow: workflow,
                                                      agents: workflow_agents)
          end
        end
      end

      # Gives deposit access to registered users to default AdminSet
      def create_default_access_for(permission_template:, workflow:)
        # OVERRIDE: do not give deposit access to the to default AdminSet to registered users if we are restricting permissions
        return if ENV['SETTINGS__RESTRICT_CREATE_AND_DESTROY_PERMISSIONS'] == 'true'

        permission_template.access_grants.create(agent_type: 'group', agent_id: ::Ability.registered_group_name, access: Hyrax::PermissionTemplateAccess::DEPOSIT)
        deposit = Sipity::Role[Hyrax::RoleRegistry::DEPOSITING]
        workflow.update_responsibilities(role: deposit, agents: Hyrax::Group.find_by!(name: ::Ability.registered_group_name))
      end

      def default_workflow_importer
        Hyrax::Workflow::WorkflowImporter.method(:load_workflow_for)
      end
  end
end
