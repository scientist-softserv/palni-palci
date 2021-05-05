# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RolesService, clean: true do
  subject(:roles_service) { described_class }
  let(:default_role_count) { described_class::ALL_DEFAULT_ROLES.count }

  describe '#find_or_create_site_role!' do
    let(:test_role_name) { 'test_role' }

    it 'requires a :role_name argument' do
      expect { roles_service.find_or_create_site_role! }
        .to raise_error(ArgumentError, 'missing keyword: role_name')
    end

    it 'returns the role' do
      expect(roles_service.find_or_create_site_role!(role_name: test_role_name))
        .to be_an_instance_of(Role)
    end

    context 'when the role does not exist' do
      it 'creates a role' do
        expect { roles_service.find_or_create_site_role!(role_name: test_role_name) }
          .to change(Role, :count).by(1)
      end
    end

    context 'when the role already exists' do
      before do
        Role.find_or_create_by!(
          name: test_role_name,
          resource_id: Site.instance.id,
          resource_type: 'Site'
        )
      end

      it 'does not create a role' do
        expect { roles_service.find_or_create_site_role!(role_name: test_role_name) }
          .to change(Role, :count).by(0)
      end

      it 'finds the site role' do
        expect(roles_service.find_or_create_site_role!(role_name: test_role_name))
          .to eq(Role.last)
      end
    end
  end

  describe '#create_default_roles!' do
    context 'when run outside the scope of a tenant' do
      let(:scope_warning) do
        '`AccountElevator.switch!` into an Account before creating default Roles'
      end

      before { allow(Site).to receive(:instance).and_return(NilSite.new) }
      after { allow(Site).to receive(:instance).and_call_original } # un-stub Site

      it 'returns a warning' do
        expect(roles_service.create_default_roles!).to eq(scope_warning)
      end
    end

    context 'when run inside the scope of a tenant' do
      it 'creates all default roles' do
        expect { roles_service.create_default_roles! }
          .to change(Role, :count).by(default_role_count)
      end

      it 'calls #find_or_create_site_role! for each role' do
        expect(roles_service)
          .to receive(:find_or_create_site_role!)
          .exactly(default_role_count).times

        roles_service.create_default_roles!
      end
    end
  end

  describe '#create_collection_accesses!' do
    let!(:collection) { FactoryBot.create(:collection_lw, with_permission_template: true) }

    context 'when a Collection already has PermissionTemplateAccess records for all of the collection roles' do
      it 'does not create any new PermissionTemplateAccess records' do
        expect { roles_service.create_collection_accesses! }
          .not_to change(Hyrax::PermissionTemplateAccess, :count)
      end

      it "does not reset the Collection's access controls unnecessarily" do
        expect_any_instance_of(Collection).not_to receive(:reset_access_controls!)

        roles_service.create_collection_accesses!
      end
    end

    context 'when a Collection does not have access records for the collection roles' do
      before do
        collection.permission_template.access_grants.map(&:destroy)
      end

      it 'creates a PermissionTemplateAccess record for each collection role' do
        expect { roles_service.create_collection_accesses! }
          .to change(Hyrax::PermissionTemplateAccess, :count)
          .by(3)
      end

      it 'creates a PermissionTemplateAccess record with MANAGE access for the :collection_manager role' do
        expect(
          access_count_for(
            'collection_manager',
            collection.permission_template,
            Hyrax::PermissionTemplateAccess::MANAGE
          )
        ).to eq(0)

        roles_service.create_collection_accesses!

        expect(
          access_count_for(
            'collection_manager',
            collection.permission_template,
            Hyrax::PermissionTemplateAccess::MANAGE
          )
        ).to eq(1)
      end

      it 'creates a PermissionTemplateAccess record with VIEW access for the :collection_editor role' do
        expect(
          access_count_for(
            'collection_editor',
            collection.permission_template,
            Hyrax::PermissionTemplateAccess::VIEW
          )
        ).to eq(0)

        roles_service.create_collection_accesses!

        expect(
          access_count_for(
            'collection_editor',
            collection.permission_template,
            Hyrax::PermissionTemplateAccess::VIEW
          )
        ).to eq(1)
      end

      it 'creates a PermissionTemplateAccess record with VIEW access for the :collection_reader role' do
        expect(
          access_count_for(
            'collection_reader',
            collection.permission_template,
            Hyrax::PermissionTemplateAccess::VIEW
          )
        ).to eq(0)

        roles_service.create_collection_accesses!

        expect(
          access_count_for(
            'collection_reader',
            collection.permission_template,
            Hyrax::PermissionTemplateAccess::VIEW
          )
        ).to eq(1)
      end

      it "resets the Collection's access controls" do
        expect_any_instance_of(Collection).to receive(:reset_access_controls!).once

        roles_service.create_collection_accesses!
      end
    end
  end

  describe '#create_collection_type_participants!' do
    context 'when the collection type already has participants for the collection roles' do
      # All non-AdminSet CollectionTypes created through the UI should automatically
      # get the :collection_manager role as a group participant with manage access
      # and the :collection_editor role as a group participant with create access
      let!(:collection_type) { FactoryBot.create(:collection_type) }

      it 'does not create any new CollectionTypeParticipant records' do
        debugger
        expect { roles_service.create_collection_type_participants! }
          .not_to change(Hyrax::CollectionTypeParticipant, :count)
      end
    end

    context 'when the collection type does not have participants for the collection roles' do
      let!(:collection_type) { FactoryBot.create(:collection_type, :without_default_participants) }

      it 'creates two CollectionTypeParticipant records' do
        expect { roles_service.create_collection_type_participants! }
          .to change(Hyrax::CollectionTypeParticipant, :count)
          .by(2)
      end

      it 'creates a CollectionTypeParticipant record with MANAGE_ACCESS for the :collection_manager role' do
        expect(
          collection_type.collection_type_participants.where(
            agent_id: 'collection_manager',
            agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE,
            access: Hyrax::CollectionTypeParticipant::MANAGE_ACCESS
          ).count
        ).to eq(0)

        roles_service.create_collection_type_participants!

        expect(
          collection_type.collection_type_participants.where(
            agent_id: 'collection_manager',
            agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE,
            access: Hyrax::CollectionTypeParticipant::MANAGE_ACCESS
          ).count
        ).to eq(1)
      end

      it 'creates a CollectionTypeParticipant record with CREATE_ACCESS for the :collection_editor role' do
        expect(
          collection_type.collection_type_participants.where(
            agent_id: 'collection_editor',
            agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE,
            access: Hyrax::CollectionTypeParticipant::CREATE_ACCESS
          ).count
        ).to eq(0)


        roles_service.create_collection_type_participants!

        expect(
          collection_type.collection_type_participants.where(
            agent_id: 'collection_editor',
            agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE,
            access: Hyrax::CollectionTypeParticipant::CREATE_ACCESS
          ).count
        ).to eq(1)
      end
    end

    context 'when the collection type is the admin set' do
      let!(:collection_type) { FactoryBot.create(:admin_set_collection_type) }

      it 'does not create any CollectionTypeParticipant records for the collection roles' do
        expect { roles_service.create_collection_type_participants! }
          .not_to change(Hyrax::CollectionTypeParticipant, :count)
      end
    end
  end

  describe '#destroy_registered_group_collection_type_participants!' do
    context 'when multiple CollectionTypes grant the registered group create access' do
      before do
        FactoryBot.create(:collection_type, creator_group: ::Ability.registered_group_name)
        FactoryBot.create(:collection_type, creator_group: ::Ability.registered_group_name)
        FactoryBot.create(:collection_type, creator_group: ::Ability.registered_group_name)
      end

      it 'destroys all CollectionTypeParticipant records that grant the registered group create access' do
        expect { roles_service.destroy_registered_group_collection_type_participants! }
          .to change(Hyrax::CollectionTypeParticipant, :count).by(-3)
      end
    end

    context 'when CollectionTypes grant access to other users/groups' do
      before do
        creator_user = FactoryBot.create(:user)
        FactoryBot.create(:collection_type, creator_user: creator_user)
        FactoryBot.create(:collection_type, creator_group: 'Test Group')
        FactoryBot.create(:collection_type, manager_group: ::Ability.admin_group_name)
        FactoryBot.create(:collection_type, manager_group: ::Ability.registered_group_name)
      end

      it 'does not destroy CollectionTypeParticipant records that do not grant the registered group create access' do
        expect { roles_service.destroy_registered_group_collection_type_participants! }
          .not_to change(Hyrax::CollectionTypeParticipant, :count)
      end
    end
  end

  describe '#prune_stale_guest_users' do
    before do
      3.times do |i|
        u = FactoryBot.create(:user)
        u.update!(updated_at: (i + 6).days.ago)
      end
    end

    it 'does not delete non-guest users' do
      expect { roles_service.prune_stale_guest_users }
        .not_to change(User.unscoped, :count)
    end

    context 'when there are guest users that have not been updated in over 7 days' do
      before do
        3.times do
          FactoryBot.create(:guest_user, stale: true)
        end
      end

      it 'deletes them' do
        expect { roles_service.prune_stale_guest_users }
          .to change(User.unscoped, :count).by(-3)
      end
    end

    context 'when there are guest users that have been updated in the last 7 days' do
      before do
        3.times do
          FactoryBot.create(:guest_user)
        end
      end

      it 'does not delete them' do
        expect { roles_service.prune_stale_guest_users }
          .not_to change(User.unscoped, :count)
      end
    end
  end

  describe '#seed_superadmin!' do
    it 'creates a user with the :superadmin role' do
      expect_any_instance_of(User).to receive(:add_default_group_memberships!).once

      superadmin_user = roles_service.seed_superadmin!

      expect(superadmin_user).to be_persisted
      expect(superadmin_user).to be_valid
      expect(superadmin_user.has_role?(:superadmin)).to eq(true)
    end

    context 'when in the production environment' do
      before { allow(Rails.env).to receive(:production?).and_return(true) }
      after { allow(Rails.env).to receive(:production?).and_call_original } # un-stub

      it 'returns a warning' do
        expect(roles_service.seed_superadmin!)
          .to eq('Seed data should not be used in the production environment')
      end

      it 'does not create the superadmin' do
        expect { roles_service.seed_superadmin! }
          .not_to change(User, :count)
      end
    end
  end

  describe '#seed_qa_users!' do
    it 'creates a user for each default role' do
      expect { roles_service.seed_qa_users! }
        .to change(User, :count)
        .by(default_role_count)
    end

    context 'when in the production environment' do
      before { allow(Rails.env).to receive(:production?).and_return(true) }
      after { allow(Rails.env).to receive(:production?).and_call_original } # un-stub

      it 'returns a warning' do
        expect(roles_service.seed_qa_users!)
          .to eq('Seed data should not be used in the production environment')
      end

      it 'does not create the qa users' do
        expect { roles_service.seed_qa_users! }
          .not_to change(User, :count)
      end
    end
  end

  def access_count_for(collection_role, permission_template, access)
    permission_template.access_grants.where(
      agent_type: Hyrax::PermissionTemplateAccess::GROUP,
      agent_id: collection_role,
      access: access
    ).count
  end
end
