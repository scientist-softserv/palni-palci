# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Dashboard', type: :feature, js: true, clean: true do
  context 'as an administrator' do
    let(:user) { FactoryBot.create(:admin) }
    let(:group) { FactoryBot.create(:group) }

    before do
      login_as(user, scope: :user)
    end

    skip 'TODO: This consistently fails the CI pipeline, but passes locally. https://github.com/scientist-softserv/palni-palci/issues/933'
    it 'shows the admin page' do # rubocop:disable RSpec/ExampleLength
      visit Hyrax::Engine.routes.url_helpers.dashboard_path
      within '.sidebar' do
        expect(page).to have_link('Activity Summary')
        expect(page).to have_link('System Status')
        expect(page).to have_link("Your activity")
        expect(page).to have_link('Reports')
        # Need to click link to open collapsed menu
        click_link "Your activity"
        expect(page).to have_link('Profile')
        expect(page).to have_link('Notifications')
        expect(page).to have_link('Transfers')
        expect(page).to have_link('Manage Proxies')
        # Should see Works and Collections
        expect(page).to have_link('Collections')
        expect(page).to have_link('Works')
        # Should see items in Tasks
        expect(page).to have_link('Review Submissions')
        expect(page).to have_link('Manage Users')
        expect(page).to have_link('Manage Groups')
        expect(page).to have_link('Manage Embargoes')
        expect(page).to have_link('Manage Leases')
        expect(page).to have_link('Settings')
        # Need to click link to open collapsed menu
        click_link "Settings"
        expect(page).to have_link('Labels')
        expect(page).to have_link('Appearance')
        expect(page).to have_link('Collection Types')
        expect(page).to have_link('Pages')
        expect(page).to have_link('Content Blocks')
        expect(page).to have_link('Features')
        expect(page).to have_link('Available Work Types')
        click_link "Features"
      end
      # TODO: I (Jeremy) commented out the code, because I find it hard to imagine that the
      #       e12067c3ac367d4bb2798ab71fbb8660 is a durable value for tests.
      #
      # the workflow roles button is only ever shown if the setting is turned on.
      # within("form[action='/admin/features/show_workflow_roles_menu_item_in_admin_dashboard_sidebar/strategies/e12067c3ac367d4bb2798ab71fbb8660?locale=en']") do
      #   find("input[value='on']").click
      # end
      # expect(page).to have_link('Workflow Roles')
    end

    it 'shows the status page' do
      visit status_path
      expect(page).to have_content("Fedora\nOK")
      expect(page).to have_content("Solr\nOK")
      expect(page).to have_content("Redis\nOK")
      expect(page).to have_content("Database\nOK")
    end

    it 'displays the add-users-to-groups page without the hidden form field', js: true do
      visit admin_group_users_path(group)
      expect(page).to have_content('Add User to Group')
      expect(page).to have_selector('.js-group-user-add', visible: false)
    end
  end

  context 'as a user' do
    let(:user) { FactoryBot.create(:user) }
    let(:group) { FactoryBot.create(:group) }

    before do
      login_as(user, scope: :user)
    end

    it 'shows the regular user page' do # rubocop:disable RSpec/ExampleLength
      visit Hyrax::Engine.routes.url_helpers.dashboard_path
      within '.sidebar' do
        expect(page).to have_link('Activity Summary')
        # Should not see System Status
        expect(page).not_to have_link('System Status')
        expect(page).to have_link("Your activity")
        # Should not see Reports
        expect(page).not_to have_link('Reports')
        # Need to click link to open collapsed menu
        click_link "Your activity"
        expect(page).to have_link('Profile')
        expect(page).to have_link('Notifications')
        expect(page).to have_link('Transfers')
        expect(page).to have_link('Manage Proxies')
        # Should see Works and Collections
        expect(page).to have_link('Collections')
        expect(page).to have_link('Works')
        # Should not see items in Tasks
        expect(page).not_to have_link('Review Submissions')
        expect(page).not_to have_link('Manage Users')
        expect(page).not_to have_link('Manage Groups')
        expect(page).not_to have_link('Manage Embargoes')
        expect(page).not_to have_link('Manage Leases')
        # Should not see Settings or Workflow Roles
        expect(page).not_to have_link('Settings')
        expect(page).not_to have_link('Workflow Roles')
      end
    end
  end
end
