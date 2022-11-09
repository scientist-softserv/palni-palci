module Hyrax
  # Used to override default behavior in Hyrax (v3.4.2)
  module WorksControllerBehaviorDecorator
    # OVERRIDE: Change this method to work around a bug in Hyrax:
    # https://github.com/samvera/hyrax/issues/5904
    #
    # To summarize, an admin should always be able to edit permissions for a given Work, even
    # if the AdminSet doesn't allow access grants.
    # However, the permissions params get thrown out if the AdminSet doesn't allow access grants,
    # regardless of the user's ability.
    # @see Hyrax::Forms::WorkForm.sanitize_params
    # https://github.com/samvera/hyrax/blob/v3.4.2/app/forms/hyrax/forms/work_form.rb#L156-L165
    def attributes_for_actor
      sanitized_attributes = super
      permissions_params = params.dig(hash_key_for_curation_concern, 'permissions_attributes')
      # Only change behavior if the user is an admin
      return sanitized_attributes unless current_ability.admin? && permissions_params.present?

      # This chunk is inspired by Hyrax::Forms::WorkForm.workflow_for
      # https://github.com/samvera/hyrax/blob/v3.4.2/app/forms/hyrax/forms/work_form.rb#L189-L197
      admin_set_id = sanitized_attributes['admin_set_id']
      begin
        workflow = Hyrax::PermissionTemplate.find_by!(source_id: admin_set_id).active_workflow
      rescue ActiveRecord::RecordNotFound
        raise "Missing permission template for AdminSet(id:#{admin_set_id})"
      end
      raise Hyrax::MissingWorkflowError, "PermissionTemplate for AdminSet(id:#{admin_set_id}) does not have an active_workflow" unless workflow
      return sanitized_attributes if workflow.allows_access_grant? # No need to alter permissions if they're allowed

      # Add stripped permissions params back to the sanitized attributes
      permissions_attributes = { 'permissions_attributes' => permissions_params }
      sanitized_attributes.merge!(permissions_attributes)
      sanitized_attributes.require('permissions_attributes').permit!

      sanitized_attributes
    end
  end
end

Hyrax::WorksControllerBehavior.prepend(Hyrax::WorksControllerBehaviorDecorator)
