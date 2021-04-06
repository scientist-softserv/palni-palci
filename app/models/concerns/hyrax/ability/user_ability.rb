module Hyrax
  module Ability
    module UserAbility
      def user_roles
        # Can create, read, edit/update, delete, and become of all Users
        if group_aware_role_checker.user_admin?
          can %i[manage], User
        # Can create, read, and edit/update destroy all Users, cannot become a User
        elsif group_aware_role_checker.user_manager?
          can %i[create read update edit destroy], User
        # Can read all Users
        elsif group_aware_role_checker.user_reader?
          can %i[read], User
        end
      end
    end
  end
end
