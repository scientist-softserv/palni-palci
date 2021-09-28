# frozen_string_literal: true

require 'rails_helper'

# For work approval permissions, see spec/features/work_approval_permissions_spec.rb
RSpec.describe 'Work Editor role', type: :feature, js: true, clean: true, cohort: 'bravo' do
  include WorksHelper

  let(:work_editor) { FactoryBot.create(:user, roles: [:work_editor]) }
  let(:work_depositor) { FactoryBot.create(:user, roles: [:work_depositor]) }
  let(:visibility) { 'open' }
  # `before`s and `let!`s are order-dependent -- do not move this `before` from the top
  before do
    FactoryBot.create(:admin_group)
    FactoryBot.create(:registered_group)
    FactoryBot.create(:editors_group)
    FactoryBot.create(:depositors_group)
  end
  let!(:admin_set) do
    admin_set = AdminSet.new(title: ['Test Admin Set'])
    allow(Hyrax.config).to receive(:default_active_workflow_name).and_return('default')
    Hyrax::AdminSetCreateService.new(admin_set: admin_set, creating_user: nil).create
    admin_set.reload
  end
  let!(:work) { process_through_actor_stack(build(:work), work_depositor, admin_set.id, visibility) }
  before do
    login_as work_editor
  end

  describe 'read permissions' do
    %w[open authenticated restricted].each do |visibility|
      context "with #{visibility} visibility" do
        let(:visibility) { visibility }

        it 'can see the work in search results' do
          visit search_catalog_path

          expect(page).to have_content(work.title.first)
        end

        it 'can see works it deposited in the dashboard' do
          my_work = process_through_actor_stack(build(:work), work_editor, admin_set.id, visibility)
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

      page.choose('generic_work_visibility_open')
      check('agreement')

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
      my_work = process_through_actor_stack(build(:work), work_editor, admin_set.id, visibility)
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
      my_work = process_through_actor_stack(build(:work), work_editor, admin_set.id, visibility)
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
end
