# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Work Editor role', type: :feature, js: true, clean: true do
  # `before`s and `let!`s are order-dependent -- do not move this `before` from the top
  before do
    FactoryBot.create(:admin_group)
    FactoryBot.create(:registered_group)
    FactoryBot.create(:editors_group)
    FactoryBot.create(:depositors_group)

    login_as work_editor

    allow(Hyrax.config).to receive(:default_active_workflow_name).and_return('default')
    Hyrax::AdminSetCreateService.new(admin_set: AdminSet.find(admin_set.id), creating_user: nil).create
  end

  let(:admin_set) { AdminSet.create!(title: ['Test Admin Set']) }
  let(:work_editor) { FactoryBot.create(:user, roles: [:work_editor]) }
  let(:work_depositor) { FactoryBot.create(:user, roles: [:work_depositor]) }
  let(:visibility) { 'open' }
  let!(:work) { create_work(depositor: work_depositor) }

  describe 'read permissions' do
    %w[open authenticated restricted].each do |visibility|
      context "with #{visibility} visibility" do
        let(:visibility) { visibility }

        it 'can see the work in search results' do
          visit search_catalog_path

          expect(page).to have_content(work.title.first)
        end

        it 'can see works it deposited in the dashboard' do
          my_work = create_work(depositor: work_editor)
          visit '/dashboard/my/works'

          expect(page).to have_content('works you own in the repository')
          expect(page).to have_content(my_work.title.first)
        end

        it 'can see works deposited by other users in the dashboard' do
          visit '/dashboard/my/works'
          click_link 'Managed Works' # switch tab

          expect(page).to have_content('works you can manage in the repository')
          expect(page).to have_content(work.title.first)
        end
      end
    end
  end

  describe 'create permissions' do
    it 'can see the "Add new work" button in the dashboard' do
      visit '/dashboard/my/works'

      expect(page).to have_link('Add new work')
    end

    it 'can see the "Share Your Work" button on the tenant homepage' do
      visit '/'

      expect(page).to have_link('Share Your Work')
    end

    it 'can create a work' do
      visit new_hyrax_generic_work_path
      fill_out_work_form

      expect { click_on('Save') }
        .to change(GenericWork, :count)
        .by(1)
    end
  end

  describe 'edit permissions' do
    it 'can see the edit button on the work show page' do
      visit hyrax_generic_work_path(work)

      expect(page).to have_selector(:link_or_button, 'Edit')
    end

    it 'can see the edit button for works it creates on the dashboard index page' do
      my_work = create_work(depositor: work_editor)
      visit '/dashboard/my/works'

      click_button('Select')
      expect(page).to have_text('Edit Work')
    end

    it 'can see the edit button for works other users create on the dashboard index page' do
      visit '/dashboard/works'

      click_button('Select')
      expect(page).to have_text('Edit Work')
    end
  end

  describe 'destroy permissions' do
    it 'cannot see the delete button on the work show page' do
      visit hyrax_generic_work_path(work)

      expect(page).not_to have_selector(:link_or_button, 'Delete')
    end

    it 'cannot see the delete button for works it creates on the dashboard index page' do
      my_work = create_work(depositor: work_editor)
      visit '/dashboard/my/works'

      click_button('Select')
      expect(page).not_to have_text('Delete Work')
    end

    it 'cannot see the delete button for works other users create on the dashboard index page' do
      visit '/dashboard/works'

      click_button('Select')
      expect(page).not_to have_text('Delete Work')
    end
  end

  # TODO: Fix specs
  xdescribe 'approve permissions' do
    it "can see the workflow actions widget on the work's show page" do
      visit hyrax_generic_work_path(work)

      expect(page).to have_content('Review and Approval')
      expect(page).to have_selector('.workflow-actions')
    end

    it 'can see works submitted for review in the dashboard' do
      visit '/dashboard'
      click_link 'Review Submissions'

      expect(page).to have_content('Review Submissions')
      expect(page).to have_content('Under Review')
      expect(page).to have_content('Published')
      expect(page).to have_content(work.title.first)
    end
  end

  # Create a work through the UI instead of with factories to more closely mirrors how the application
  # functions in reality, prmiarily because the work will travel through the actor stack.
  # This is important when testing permissions because it ensures all the permission-related records
  # (e.g. Hydra::AccessControls::Permission, Hyrax::PermissionTemplateAccess, etc.) get created.
  def create_work(depositor:)
    # The depositor is set using #current_user in the controller and receives edit permissions
    # by default. To test the "global" nature of the :work_editor Role's permissions, most tests
    # test against another user's work.
    login_as depositor

    visit new_hyrax_generic_work_path
    fill_out_work_form
    page.click_on('Save')

    # Log back in as the user being tested if it was changed
    login_as work_editor unless depositor == work_editor

    GenericWork.where(title: 'WE Feature Spec Work').first
  end

  # Minimum valid data for a GenericWork
  def fill_out_work_form
    click_link 'Relationships' # switch tab
    select(admin_set.title.first, from: 'Administrative Set')

    click_link 'Files' # switch tab
    within('span#addfiles') do
      attach_file("files[]", Rails.root.join('spec', 'fixtures', 'images', 'image.jp2'), visible: false)
    end
    click_link 'Descriptions' # switch tab
    fill_in('Title', with: 'WE Feature Spec Work')
    fill_in('Creator', with: 'Test Creator')
    fill_in('Keyword', with: 'testing')
    select('In Copyright', from: 'Rights Statement')

    page.choose("generic_work_visibility_#{visibility}")
    check('agreement')
  end
end
