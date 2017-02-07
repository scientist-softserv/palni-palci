require 'rails_helper'

RSpec.describe 'Admin Dashboard' do
  context 'as an administrator' do
    let(:user) { FactoryGirl.create(:admin) }

    before do
      login_as(user, scope: :user)
    end

    it 'shows the admin page' do
      visit Hyrax::Engine.routes.url_helpers.admin_path
      within '#sidebar' do
        expect(page).to have_link('Activity summary')
        expect(page).to have_link('Profile')
        expect(page).to have_link('Notifications')
        expect(page).to have_link('Transfers')
        expect(page).to have_link('Labels')
        expect(page).to have_link('Appearance')
        expect(page).to have_link('Content Blocks')
        expect(page).to have_link('Technical')
        expect(page).to have_link('Administrative Sets')
        expect(page).to have_link('Manage groups')
        expect(page).to have_link('Manage users')
        expect(page).to have_link('Reports')
      end
    end

    it 'shows the status page' do
      visit status_path
      expect(page).to have_content('Fedora OK')
      expect(page).to have_content('Solr OK')
      expect(page).to have_content('Redis OK')
      expect(page).to have_content('Database OK')
    end
  end
end
