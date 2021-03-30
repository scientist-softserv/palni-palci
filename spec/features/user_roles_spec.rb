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
    let!(:user_manager_role) { FactoryBot.create(:user_manager_role) }
    let!(:user_reader_role) { FactoryBot.create(:user_reader_role) }
    let(:user_admin) { FactoryBot.create(:user_admin) }

    before do
      login_as(user_admin, scope: :user)
    end

    it 'cannot revoke or change a superadmins role' do
      visit proprietor_user_path(superadmin)
      expect(page).to have_field 'superadmin', disabled: true
      expect(page).to have_field 'user_admin', disabled: false
      expect(page).to have_field 'user_manager', disabled: false
      expect(page).to have_field 'user_reader', disabled: false
    end
  end
 
  context 'as an admin_manager' do
    let!(:superadmin) { FactoryBot.create(:superadmin) }
    let(:user_manager) { FactoryBot.create(:user_manager) }
    let!(:user_reader_role) { FactoryBot.create(:user_reader_role) }
    let!(:user_admin_role) { FactoryBot.create(:user_admin_role) }

    before do
      login_as(user_manager, scope: :user)
    end

    it 'cannot revoke or change a superadmins role' do
      visit proprietor_user_path(superadmin)
      expect(page).to have_field 'superadmin', disabled: true
      expect(page).to have_field 'user_admin', disabled: false
      expect(page).to have_field 'user_manager', disabled: false
      expect(page).to have_field 'user_reader', disabled: false
    end
  end

  context 'as a superadmin' do
    let(:superadmin) { FactoryBot.create(:superadmin) }
    let!(:user_admin) { FactoryBot.create(:user_admin) }
    let!(:user_reader_role) { FactoryBot.create(:user_reader_role) }
    let!(:user_manager_role) { FactoryBot.create(:user_manager_role) }

    before do
      login_as(superadmin, scope: :user)
    end

    it 'can revoke or change a user_admin role' do
      visit proprietor_user_path(user_admin)
      expect(page).to have_field 'superadmin', disabled: false
      expect(page).to have_field 'user_admin', disabled: false
      expect(page).to have_field 'user_manager', disabled: false
      expect(page).to have_field 'user_reader', disabled: false
    end
  end

  context 'as a superadmin' do
    let(:superadmin) { FactoryBot.create(:superadmin) }
    let!(:superadmin_2) { FactoryBot.create(:superadmin) }
    let!(:user_reader_role) { FactoryBot.create(:user_reader_role) }
    let!(:user_manager_role) { FactoryBot.create(:user_manager_role) }
    let!(:user_admin_role) { FactoryBot.create(:user_admin_role) }

    before do
      login_as(superadmin, scope: :user)
    end

    it 'can revoke or change a superadmin role' do
      visit proprietor_user_path(superadmin_2)
      expect(page).to have_field 'superadmin', disabled: false
      expect(page).to have_field 'user_admin', disabled: false
      expect(page).to have_field 'user_manager', disabled: false
      expect(page).to have_field 'user_reader', disabled: false
    end
  end

  # CAN CHANGE A USERS ROLE AS SUPERADMIN
  context 'as a superadmin' do
    let(:user) { FactoryBot.create(:user) }
    let(:superadmin) { FactoryBot.create(:superadmin) }
    let!(:user_reader_role) { FactoryBot.create(:user_reader_role) }
    let!(:user_manager_role) { FactoryBot.create(:user_manager_role) }
    let!(:user_admin_role) { FactoryBot.create(:user_admin_role) }

    before do
      login_as(superadmin, scope: :user)
    end

    it 'can change a users role' do
      visit proprietor_user_path(user)
      expect(user.has_role?(:user_manager)).to be false
      expect(user.has_role?(:user_admin)).to be false
      expect(user.has_role?(:user_reader)).to be false
      expect(user.has_role?(:superadmin)).to be false
      check 'user_admin'
      click_button 'Update'
      expect(page).to have_content "User was successfully updated."
      expect(user.has_role?(:user_admin)).to be true
      expect(user.has_role?(:user_manager)).to be false
      expect(user.has_role?(:user_reader)).to be false
      expect(user.has_role?(:superadmin)).to be false
    end
  end

  # CAN REMOVE A USERS ROLE AS SUPERADMIN
  context 'as a superadmin' do
    let(:user_manager) { FactoryBot.create(:user_manager) }
    let(:superadmin) { FactoryBot.create(:superadmin) }
    let!(:user_reader_role) { FactoryBot.create(:user_reader_role) }
    let!(:user_admin_role) { FactoryBot.create(:user_admin_role) }

    before do
      login_as(superadmin, scope: :user)
    end

    it 'can remove a users role' do
      visit proprietor_user_path(user_manager)
      expect(user_manager.has_role?(:user_manager)).to be true
      uncheck 'user_manager'
      click_button 'Update'
      expect(page).to have_content "User was successfully updated."
      expect(user_manager.reload.has_role?(:user_manager)).to be false
    end
  end

  # CAN CHANGE A USERS ROLE AS USER_MANAGER
  context 'as a user_manager' do
    let(:user_manager) { FactoryBot.create(:user_manager) }
    let!(:user_reader_role) { FactoryBot.create(:user_reader_role) }
    let(:user_admin) { FactoryBot.create(:user_admin) }
    let!(:user_manager_role) { FactoryBot.create(:user_manager_role) }
    let!(:superadmin) { FactoryBot.create(:superadmin) }

    before do
      login_as(user_manager, scope: :user)
    end

    it 'can change a users role' do
      visit proprietor_user_path(user_admin)
      expect(user_admin.has_role?(:user_reader)).to be false
      expect(user_admin.has_role?(:user_admin)).to be true
      uncheck 'user_admin'
      check 'user_reader'
      click_button 'Update'
      expect(page).to have_content "User was successfully updated."
      expect(user_admin.reload.has_role?(:user_admin)).to be false
      expect(user_admin.reload.has_role?(:user_reader)).to be true
    end
  end

  # CAN REMOVE A USERS ROLE AS USER_MANAGER
  context 'as a user_manager' do
    let(:user_manager) { FactoryBot.create(:user_manager) }
    let(:user_admin) { FactoryBot.create(:user_admin) }
    let!(:user_reader_role) { FactoryBot.create(:user_reader_role) }
    let!(:user_manager_role) { FactoryBot.create(:user_manager_role) }
    let!(:superadmin) { FactoryBot.create(:superadmin) }

    before do
      login_as(user_manager, scope: :user)
    end

    it 'can remove a users role' do
      visit proprietor_user_path(user_admin)
      expect(user_admin.has_role?(:user_admin)).to be true
      uncheck 'user_admin'
      click_button 'Update'
      expect(page).to have_content "User was successfully updated."
      expect(user_admin.reload.has_role?(:user_admin)).to be false
    end
  end

  # CAN CHANGE A USERS ROLE AS USER_ADMIN
  context 'as a user_admin' do
    let(:user_admin) { FactoryBot.create(:user_admin) }
    let(:user_manager) { FactoryBot.create(:user_manager) }
    let!(:user_reader_role) { FactoryBot.create(:user_reader_role) }
    let!(:user_admin_role) { FactoryBot.create(:user_admin_role) }
    let!(:superadmin) { FactoryBot.create(:superadmin) }

    before do
      login_as(user_admin, scope: :user)
    end

    it 'can change a users role' do
      visit proprietor_user_path(user_manager)
      expect(user_manager.has_role?(:user_manager)).to be true
      expect(user_manager.has_role?(:user_admin)).to be false
      check 'user_admin'
      uncheck 'user_manager'
      click_button 'Update'
      expect(page).to have_content "User was successfully updated."
      expect(user_manager.reload.has_role?(:user_manager)).to be false
      expect(user_manager.reload.has_role?(:user_admin)).to be true
    end
  end

  # CAN REMOVE A USERS ROLE AS USER_ADMIN
  context 'as a user_admin' do
    let(:user_admin) { FactoryBot.create(:user_admin) }
    let(:user_manager) { FactoryBot.create(:user_manager) }
    let!(:user_reader_role) { FactoryBot.create(:user_reader_role) }
    let!(:superadmin) { FactoryBot.create(:superadmin) }

    before do
      login_as(user_admin, scope: :user)
    end

    it 'can remove a users role' do
      visit proprietor_user_path(user_manager)
      expect(user_manager.has_role?(:user_manager)).to be true
      uncheck 'user_manager'
      click_button 'Update'
      expect(page).to have_content "User was successfully updated."
      expect(user_manager.reload.has_role?(:user_manager)).to be false
    end
  end

  # CAN ADD MULTIPLE ROLES TO A USER
  context 'as a superadmin' do
    let!(:user) { FactoryBot.create(:user) }
    let(:superadmin) { FactoryBot.create(:superadmin) }
    let!(:user_reader_role) { FactoryBot.create(:user_reader_role) }
    let!(:user_admin_role) { FactoryBot.create(:user_admin_role) }
    let!(:user_manager_role) { FactoryBot.create(:user_manager_role) }

    before do
      login_as(superadmin, scope: :user)
    end

    it 'can add multiple roles to a user' do
      visit proprietor_user_path(user)
      expect(user.has_role?(:user_admin)).to be false
      expect(user.has_role?(:user_manager)).to be false
      expect(user.has_role?(:user_reader)).to be false
      check 'user_admin'
      check 'user_manager'
      check 'user_reader'
      click_button 'Update'
      expect(page).to have_content "User was successfully updated."
      expect(user.has_role?(:user_manager)).to be true
      expect(user.has_role?(:user_admin)).to be true
      expect(user.has_role?(:user_reader)).to be true
    end
  end

  context 'as a superadmin' do
    let!(:user) { FactoryBot.create(:user) }
    let(:superadmin) { FactoryBot.create(:superadmin) }

    before do
      login_as(superadmin, scope: :user)
    end

    it 'can become another user' do
      visit proprietor_users_path
      find("a[href='#{become_proprietor_user_path(user.id)}?locale=en']").click
      expect(page).to have_content 'User changed successfully'
      expect(page).to have_no_content 'Users'
    end
  end

end
