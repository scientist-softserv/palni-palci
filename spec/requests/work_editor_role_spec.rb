# frozen_string_literal: true

RSpec.describe 'Work Editor role', type: :request, singletenant: true, clean: true do
  # `before`s and `let!`s are order-dependent -- do not move this `before` from the top
  before do
    FactoryBot.create(:admin_group)
    FactoryBot.create(:registered_group)
    FactoryBot.create(:editors_group)
    FactoryBot.create(:depositors_group)

    login_as work_editor

    allow(Hyrax.config).to receive(:default_active_workflow_name).and_return('default')
    Hyrax::AdminSetCreateService.new(admin_set: AdminSet.find(admin_set_id), creating_user: nil).create
  end

  let(:admin_set_id) { AdminSet.create!(title: ['Test Admin Set']).id }
  let(:work_editor) { FactoryBot.create(:user, roles: [:work_editor]) }
  let(:work_depositor) { FactoryBot.create(:user, roles: [:work_depositor]) }
  let(:visibility) { 'open' }
  let!(:work) { create_work(depositor: work_depositor) }
  let(:valid_work_params) do
    {
      generic_work: {
        title: ['Test Work'],
        creator: ['depositor@example.com'],
        keyword: ['asdf'],
        rights_statement: 'http://rightsstatements.org/vocab/CNE/1.0/',
        visibility: visibility,
        admin_set_id: admin_set_id
      }
    }
  end

  describe 'read permissions' do
    %w[open authenticated restricted].each do |visibility|
      context "with #{visibility} visibility" do
        let(:visibility) { visibility }

        it 'can see the show page for works it deposited' do
          my_work = create_work(depositor: work_editor)
          get hyrax_generic_work_path(my_work)

          expect(response).to have_http_status(:success)
        end

        it 'can see the show page for works deposited by other users' do
          get hyrax_generic_work_path(work)

          expect(response).to have_http_status(:success)
        end

        it 'can see works it deposited in the dashboard' do
          my_work = create_work(depositor: work_editor)
          get '/dashboard/my/works'

          expect(response).to have_http_status(:success)
        end

        it 'can see works deposited by other users in the dashboard' do
          get '/dashboard/works'

          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe 'create permissions' do
    it 'can see the work form' do
      get new_hyrax_generic_work_path

      expect(response).to have_http_status(:success)
    end

    it 'can create a work' do
      expect { post hyrax_generic_works_path, params: valid_work_params }
        .to change(GenericWork, :count).by(1)
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'edit permissions' do
    it 'can edit works deposited by other users' do
      get edit_hyrax_generic_work_path(work)

      expect(response).to have_http_status(:success)
    end

    it 'can edit works it deposited' do
      my_work = create_work(depositor: work_editor)
      get edit_hyrax_generic_work_path(my_work)

      expect(response).to have_http_status(:success)
    end
  end

  describe 'destroy permissions' do
    it 'cannot destroy the work' do
      expect { delete hyrax_generic_work_path(work) }
        .not_to change(GenericWork, :count)
    end
  end

  # TODO: Fix specs. The admin set still gets the default workflow, meaning
  # the work skips the review step causing the test to fail.
  xdescribe 'approve permissions' do
    let(:admin_set_id) { AdminSet.create!(title: ['Mediated Admin Set']).id }

    before do
      allow(Hyrax.config).to receive(:default_active_workflow_name).and_return('hyku_commons_mediated_deposit')
      Hyrax::AdminSetCreateService.new(admin_set: AdminSet.find(admin_set_id), creating_user: nil).create
    end

    it 'can approve a work' do
      expect(work.to_sipity_entity.workflow_state.name).to eq('pending_review')

      put hyrax_workflow_action(work), params: { workflow_actions: { name: 'approve', comment: '' } }

      expect(work.to_sipity_entity.workflow_state.name).to eq('deposited')
    end

    it 'can see works submitted for review in the dashboard' do
      get '/admin/workflows'

      expect(response).to have_http_status(:success)
    end
  end

  # Using #post to create a work instead of factories more closely mirrors how the application
  # functions in reality, prmiarily because the work will travel through the actor stack.
  # This is important when testing permissions because it ensures all the permission-related records
  # (e.g. Hydra::AccessControls::Permission, Hyrax::PermissionTemplateAccess, etc.) get created.
  def create_work(depositor:)
    # The depositor is set using #current_user in the controller and receives edit permissions
    # by default. To test the "global" nature of the :work_editor Role's permissions, most tests
    # test against another user's work.
    login_as depositor

    post hyrax_generic_works_path, params: valid_work_params

    # Log back in as the user being tested (if it was changed)
    login_as work_editor unless depositor == work_editor

    GenericWork.where(title: valid_work_params.dig(:generic_work, :title)).first
  end
end
