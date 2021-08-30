# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AdminSet form Participants tab', type: :feature, js: true, clean: true, cohort: 'alpha' do
  include Warden::Test::Helpers

  context 'as an admin user' do
    # `before`s and `let!`s are order-dependent -- do not move this `before` from the top
    before do
      FactoryBot.create(:admin_group)
      FactoryBot.create(:registered_group)
      FactoryBot.create(:editors_group)
      FactoryBot.create(:depositors_group)
    end

    let(:admin) { FactoryBot.create(:admin) }
    let!(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let!(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let!(:workflow) do
      Sipity::Workflow.create!(
        active: true,
        name: 'test-workflow',
        permission_template: permission_template
      )
    end

    before do
      login_as admin
    end

    context 'add group participants' do
      let!(:group) { FactoryBot.create(:group, name: 'dummy') }

      before do
        visit "/admin/admin_sets/#{ERB::Util.url_encode(admin_set_id)}/edit#participants"

        expect(page).to have_content('Add Participants')
        expect(page).to have_content('Add group')
        expect(managers_table).not_to have_content('dummy')
        expect(depositors_table).not_to have_content('dummy')
        expect(viewers_table).not_to have_content('dummy')
      end

      it 'displays the groups humanized name' do
        expect(page.has_select?('permission_template_access_grants_attributes_0_agent_id', with_options: [group.humanized_name])).to be true
      end

      it 'can add a group as a Manager of the admin set' do
        within('form#group-participants-form') do
          find('select#permission_template_access_grants_attributes_0_agent_id option', text: 'Group dummy').click
          find('select#permission_template_access_grants_attributes_0_access option', text: 'Manager').click
          find('input.btn-info').click
        end

        expect(managers_table).to have_content('dummy')
        expect(depositors_table).not_to have_content('dummy')
        expect(viewers_table).not_to have_content('dummy')
      end

      it 'can add a group as a Depositor of the admin set' do
        within('form#group-participants-form') do
          find('select#permission_template_access_grants_attributes_0_agent_id option', text: 'dummy').click
          find('select#permission_template_access_grants_attributes_0_access option', text: 'Depositor').click
          find('input.btn-info').click
        end

        expect(managers_table).not_to have_content('dummy')
        expect(depositors_table).to have_content('dummy')
        expect(viewers_table).not_to have_content('dummy')
      end

      it 'can add a group as a Viewer of the admin set' do
        within('form#group-participants-form') do
          find('select#permission_template_access_grants_attributes_0_agent_id option', text: 'dummy').click
          find('select#permission_template_access_grants_attributes_0_access option', text: 'Viewer').click
          find('input.btn-info').click
        end

        expect(managers_table).not_to have_content('dummy')
        expect(depositors_table).not_to have_content('dummy')
        expect(viewers_table).to have_content('dummy')
      end
    end
  end

  private

    def managers_table
      all('table.share-status')[0]
    end

    def depositors_table
      all('table.share-status')[1]
    end

    def viewers_table
      all('table.share-status')[2]
    end
end
