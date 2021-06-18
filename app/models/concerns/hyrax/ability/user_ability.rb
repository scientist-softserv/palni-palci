module Hyrax
  module Ability
    module UserAbility
      def user_roles
        # Can create, read, and edit/update destroy all Users, cannot become a User
        if group_aware_role_checker.user_manager?
          can %i[create read update edit remove], User
          can %i[create read update edit remove destroy], Hyrax::Group
        # Can read all Users and Groups
        elsif group_aware_role_checker.user_reader?
          can %i[read], User
          can :read, Hyrax::Group
        end
      end
    end
  end
end
