# frozen_string_literal: true

require 'rails_helper'

# NOTE: If you generated more than one work, you have to set 'js: true'
RSpec.describe 'Create a GenericWork', type: :feature, js: true, clean: true do
  include Warden::Test::Helpers

  context 'a logged in user with the :work_depositor role' do
    let(:user) { create(:user, roles: [:work_depositor]) }
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let(:workflow) do
      Sipity::Workflow.create!(
        active: true,
        name: 'test-workflow',
        permission_template: permission_template
      )
    end

    before do
      create(:admin_group)
      create(:registered_group)
      create(:editors_group)
      create(:depositors_group)
      # Create a single action that can be taken
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

      # Grant the user access to deposit into the admin set.
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'user',
        agent_id: user.user_key,
        access: 'deposit'
      )
      login_as user
    end

    it do # rubocop:disable RSpec/ExampleLength
      visit '/dashboard/my/works'
      click_link 'Add New Work'

      # If you generate more than one work uncomment these lines
      choose 'payload_concern', option: 'GenericWork'
      click_button 'Create work'

      # expect(page).to have_content 'Add New Work'
      click_link 'Files' # switch tab
      expect(page).to have_content 'Add files'
      expect(page).to have_content 'Add folder'
      within('div#add-files') do
        attach_file('files[]', File.join(fixture_path, 'hyrax', 'image.jp2'), visible: false)
        attach_file('files[]', File.join(fixture_path, 'hyrax', 'jp2_fits.xml'), visible: false)
      end
      expect(page).to have_selector(:link_or_button, 'Delete') # Wait for files to finish uploading

      click_link 'Descriptions' # switch tab
      fill_in('Title', with: 'My Test Work')
      fill_in('Creator', with: 'Doe, Jane')
      select('In Copyright', from: 'Rights statement')
      fill_in('Date Created', with: '09/03/2022')
      select('Thesis', from: 'Resource type')
      select('Oblate School of Theology', from: 'Institution')
      select('Image', from: 'Type')
      click_on('Additional fields')
      fill_in('Alternative title', with: 'Alternative title')
      fill_in('Contributor', with: 'Contributor')
      # rubocop:disable Metrics/LineLength
      fill_in('Description', with: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim doneci. This is past 300 characters')
      # rubocop:enable Metrics/LineLength
      fill_in('Abstract', with: 'Abstract')
      fill_in('Keyword', with: 'Keyword')
      select('Creative Commons BY Attribution 4.0 International', from: 'License')
      fill_in('Access Rights', with: 'Access Rights')
      fill_in('Rights notes', with: 'Rights notes')
      fill_in('Publisher', with: 'Publisher')
      fill_in('Subject', with: 'Subject')
      fill_in('Language', with: 'Language')
      fill_in('Identifier (local)', with: 'ISBN:978-83-7659-303-6 978-3-540-49698-4 9790879392788')
      fill_in('Related URL', with: 'https://test.hyku.test')
      fill_in('Source', with: 'Source')
      select('PDF', from: 'Format')
      fill_in('Bibliographic citation', with: 'Bibliographic citation')
      fill_in('Access Rights', with: 'Access Rights')
      fill_in('Rights notes', with: 'Rights notes')
      page.choose('generic_work_visibility_open')
      # rubocop:disable Metrics/LineLength
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      # rubocop:enable Metrics/LineLength
      find('#agreement').click

      click_on('Save')
      expect(page).to have_content('My Test Work')
      expect(page).to have_content 'Your files are being processed by Hyku in the background.'
    end
  end
end
