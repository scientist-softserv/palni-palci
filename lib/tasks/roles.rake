namespace :hyku do
  namespace :roles do
    desc 'Create all default Roles and Hyrax::Groups in all tenants'
    task create_default_roles_and_groups: :environment do
      Account.find_each do |account|
        AccountElevator.switch!(account.cname)
        Rails.logger.info("Creating default Roles and Hyrax::Groups for #{account.cname}")

        RolesService.create_default_roles!
        Hyrax::GroupsService.create_default_hyrax_groups!
      end
    end

    desc 'Create Hyrax::PermissionTemplateAccess records for collection roles in all Collections'
    task create_collection_accesses: :environment do
      Account.find_each do |account|
        AccountElevator.switch!(account.cname)
        Rails.logger.info("Creating default collection role Hyrax::PermissionTemplateAccess records for all Collections in #{account.cname}")

        RolesService.create_collection_accesses!
      end
    end

    desc 'Create Hyrax::CollectionTypeParticipant records for collection roles in all Collection Types'
    task create_collection_type_participants: :environment do
      Account.find_each do |account|
        AccountElevator.switch!(account.cname)
        Rails.logger.info("Creating default collection role Hyrax::CollectionTypeParticipant records for all Collection Types in #{account.cname}")

        RolesService.create_collection_type_participants!
      end
    end

    desc 'Destroy Hyrax::CollectionTypeParticipant records for registered users in all Collection Types'
    task destroy_registered_group_collection_type_participants: :environment do
      puts "\n This will remove create access from all Collection Types for all registered users in ALL tenants, continue? [y/n]"
      answer = STDIN.gets.chomp
      return false unless answer == 'y'

      Account.find_each do |account|
        AccountElevator.switch!(account.cname)
        Rails.logger.info("Destroying Hyrax::CollectionTypeParticipant records for registered users in all Collection Types in #{account.cname}")

        RolesService.destroy_registered_group_collection_type_participants!
      end
    end

    desc 'Create a User with the superadmin Role'
    task seed_superadmin: :environment do
      RolesService.seed_superadmin!
    end

    desc 'Create QA users with roles'
    task seed_qa_users: :environment do
      RolesService.seed_qa_users!
    end
  end
end
