# frozen_string_literal: true

# One auth to rule them all!
# Tie together all the concepts of auth in Hyrax, Hyku, and their dependencies.
# TODO: turn this into a module and include it in Ability if all it ends
# up doing is checking for roles
class GroupAwareRoleChecker

  attr_reader :user

  # @param [User] The User for whom the permissions will be evaluated.
  def initialize(user:)
    @user = user
  end

  # Dynamically define all #<role_name>? methods so that, as more roles are added,
  # their role checker methods are automatically defined
  RolesService::ALL_DEFAULT_ROLES.each do |role_name|
    define_method(:"#{role_name}?") do
      has_group_aware_role?(role_name)
    end
  end

  private

  # Check for the presence of the passed role_name in the User's Roles and
  # the User's Hyrax::Group's Roles.
  # TODO: investigate why this method causes spec/features/appearance_theme_spec.rb to fail
  def has_group_aware_role?(role_name)
    return false if @user.new_record?

    @user.reload # Get the most up-to-date version of the User before checking for Role
    return true if @user.has_role?(role_name, Site.instance)

    @user.hyrax_groups.each do |group|
      return true if group.roles.map(&:name).include?(role_name)
    end

    false
  end
end