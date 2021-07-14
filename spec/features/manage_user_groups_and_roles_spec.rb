# frozen_string_literal: true

require 'rails_helper'
RSpec.describe "The Manage Users table", type: :feature, js: true, clean: true do
  include Warden::Test::Helpers

  context 'as an admin user' do
    let(:admin_role) { create(:role, :admin) }
    let(:collection_manager_role) { create(:role, :collection_manager) }
    let(:user_manager_role) { create(:role, :user_manager) }

    let!(:admin_group) { create(:group, humanized_name: 'Rockets', member_users: [admin], roles: [admin_role.name]) }
    let!(:user_group) { create(:group, humanized_name: 'Trains', member_users: [user], roles: [user_manager_role.name]) }

    let(:admin) { create(:admin) }
    let(:user) { create(:user) }

    before do
      user.add_role(collection_manager_role.name, Site.instance)
      login_as admin
    end

    it "lists each user's associated groups' humanized names" do
      visit '/admin/users'
      expect(page).to have_content('Manage Users')
      expect(page).to have_css 'th', text: 'Groups'
      expect(find("tr##{admin.email.parameterize} td.groups")).to have_text(admin_group.humanized_name)
      expect(find("tr##{user.email.parameterize} td.groups")).to have_text(user_group.humanized_name)
    end

    it "lists each user's associated direct and inherited roles" do
      visit '/admin/users'
      expect(page).to have_content('Manage Users')
      expect(page).to have_css 'th', text: 'Roles'
      expect(find("tr##{admin.email.parameterize} td.roles")).to have_text(admin_role.name.titlecase)
      expect(find("tr##{user.email.parameterize} td.roles")).to have_text(user_manager_role.name.titlecase)
      expect(find("tr##{user.email.parameterize} td.roles")).to have_text(collection_manager_role.name.titlecase)
    end

  end
end
