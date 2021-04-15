# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupAwareRoleChecker, clean: true do
  let(:user) { FactoryBot.create(:user) }
  let(:guest_user) { FactoryBot.create(:guest_user) }
  let(:group_aware_role_checker) { GroupAwareRoleChecker.new(user: user) }

  it 'can be initialized' do
    expect(group_aware_role_checker).to be_an_instance_of(described_class)
  end

  context 'finding the user' do
    it 'can accept a user' do
      expect(group_aware_role_checker.user).to eq(user)
    end

    context 'guest users' do
      let(:user) { guest_user }

      it 'can accept a guest user' do
        expect(group_aware_role_checker.user).to eq(user)
      end
    end
  end

  # Dynamically test all #<role_name>? methods so that, as more roles are added,
  # their role checker methods are automatically covered
  RolesService::ALL_DEFAULT_ROLES.each do |role_name|
    context "when the User has the :#{role_name} role" do
      before do
        user.add_role(role.name)
      end

      describe "##{role_name}?" do
        let(:role) { FactoryBot.create(:"#{role_name}_role") }

        it { expect(group_aware_role_checker.public_send("#{role_name}?")).to eq(true) }
      end
    end

    context "when the User has a Hyrax::Group membership that includes the :#{role_name} role" do
      before do
        hyrax_group.roles << role
        hyrax_group.add_members_by_id(user.id)
      end

      describe "##{role_name}?" do
        let(:role) { FactoryBot.create(:"#{role_name}_role") }
        let(:hyrax_group) { FactoryBot.create(:group, name: "#{role_name.titleize}s") }

        it { expect(group_aware_role_checker.public_send("#{role_name}?")).to eq(true) }
      end
    end

    context "when neither the User nor the User's Hyrax::Groups have the :#{role_name} role" do
      describe "##{role_name}?" do
        it { expect(group_aware_role_checker.public_send("#{role_name}?")).to eq(false) }
      end
    end
  end
end
