# frozen_string_literal: true

# NOTE: If want to run spec in browser, you have to set "js: true"
RSpec.describe 'User Roles', multitenant: true do

  around do |example|
    default_host = Capybara.default_host
    Capybara.default_host = Capybara.app_host || "http://#{Account.admin_host}"
    example.run
    Capybara.default_host = default_host
  end

  context 'as an user admin' do
    let(:user_admin) { FactoryBot.create(:user_admin) }

    before do
      login_as(user_admin, scope: :user)
    end

    it 'can view Users section and all abilities related to user_admin' do
      visit '/'
      click_on 'Users'
      expect(page).to have_content 'Manage Users'
      expect(page).to have_link 'Manage'
      expect(page).to have_link 'Edit'
      expect(page).to have_link 'Delete'
      expect(page).to have_link 'Become'
    end
  end

  context 'as an user manager' do
    let(:user_manager) { FactoryBot.create(:user_manager) }

    before do
      login_as(user_manager, scope: :user)
    end

    it 'can view Users section and all abilities related to user_manager' do
      visit '/'
      click_on 'Users'
      expect(page).to have_content 'Manage Users'
      expect(page).to have_link 'Manage'
      expect(page).to have_link 'Edit'
      expect(page).to have_link 'Delete'
      expect(page).to_not have_link 'Become'
    end
  end

  context 'as an user reader' do
    let(:user_reader) { FactoryBot.create(:user_reader) }

    before do
      login_as(user_reader, scope: :user)
    end

    it 'can view Users section with no abilities' do
      visit '/'
      click_on 'Users'
      expect(page).to have_content 'View Users'
      expect(page).to_not have_link 'Manage'
      expect(page).to_not have_link 'Edit'
      expect(page).to_not have_link 'Delete'
      expect(page).to_not have_link 'Become'
    end
  end

  context 'as a regular user with no user roles' do
    let(:user) { FactoryBot.create(:user) }

    before do
      login_as(user, scope: :user)
    end

    it 'cannot view the User link' do
      visit '/'
      expect(page).to_not have_link 'Users'
    end
  end

end
