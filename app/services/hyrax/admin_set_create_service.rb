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
        # OVERRIDE: Extract and expand upon granting Workflow Roles into service object so it can be used in RolesService
        Hyrax::Workflow::PermissionGrantor.grant_default_workflow_roles!(permission_template: permission_template, creating_user: creating_user)
        Sipity::Workflow.activate!(permission_template: permission_template, workflow_name: Hyrax.config.default_active_workflow_name)
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
