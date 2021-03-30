# frozen_string_literal: true

# NOTE: If want to run spec in browser, you have to set "js: true"
RSpec.describe 'User Roles', multitenant: true do

  around do |example|
    default_host = Capybara.default_host
    Capybara.default_host = Capybara.app_host || "http://#{Account.admin_host}"
    example.run
    Capybara.default_host = default_host
  end

  context 'as a user admin' do
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

  context 'as a user manager' do
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

  context 'as a user reader' do
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

  context 'as a user_admin' do
    let!(:superadmin) { FactoryBot.create(:superadmin) }
    let!(:user_manager) { FactoryBot.create(:user_manager) }
    let!(:user_reader) { FactoryBot.create(:user_reader) }
    let(:user_admin) { FactoryBot.create(:user_admin) }

    before do
      login_as(user_admin, scope: :user)
    end

    it 'cannot revoke or change a superadmins role' do
      visit proprietor_user_path(superadmin)
      expect(page).to have_content 'superadmin'
      expect(page).to have_content 'user_admin'
      expect(page).to have_content 'user_reader'
      expect(page).to have_content 'user_manager'
      expect(page).to have_field('user_role_ids_1', type: 'checkbox', disabled: true)
      expect(page).to have_field('user_role_ids_2', type: 'checkbox', disabled: false)
      expect(page).to have_field('user_role_ids_4', type: 'checkbox', disabled: false)
      expect(page).to have_field('user_role_ids_5', type: 'checkbox', disabled: false)
    end
  end

  context 'as an admin_manager' do
    let!(:superadmin) { FactoryBot.create(:superadmin) }
    let(:user_manager) { FactoryBot.create(:user_manager) }

    before do
      login_as(user_manager, scope: :user)
    end

    it 'cannot revoke or change a superadmins role' do
      visit proprietor_user_path(superadmin)
      expect(page).to have_content 'superadmin'
      expect(page).to have_content 'user_manager'
      expect(page).to have_field('user_role_ids_1', type: 'checkbox', disabled: true)
    end
  end

  context 'as a superadmin' do
    let(:superadmin) { FactoryBot.create(:superadmin) }
    let!(:user_admin) { FactoryBot.create(:user_admin) }

    before do
      login_as(superadmin, scope: :user)
    end

    it 'can revoke or change a user_admin role' do
      visit proprietor_user_path(user_admin)
      expect(page).to have_content 'superadmin'
      expect(page).to have_content 'user_admin'
      expect(page).to have_field('user_role_ids_1', type: 'checkbox', disabled: false)
    end
  end

  context 'as a superadmin' do
    let(:superadmin) { FactoryBot.create(:superadmin) }
    let!(:superadmin_2) { FactoryBot.create(:superadmin) }

    before do
      login_as(superadmin, scope: :user)
    end

    it 'can revoke or change a superadmin role' do
      visit proprietor_user_path(superadmin_2)
      expect(page).to have_content 'superadmin'
      expect(page).to have_field('user_role_ids_1', type: 'checkbox', disabled: false)
    end
  end

end
