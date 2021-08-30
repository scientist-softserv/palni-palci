# frozen_string_literal: true

RSpec.describe 'Work Depositor role', type: :request, singletenant: true, clean: true do
  let(:work_depositor) { FactoryBot.create(:user, roles: [:work_depositor]) }

  before do
    FactoryBot.create(:admin_group)
    FactoryBot.create(:registered_group)
    FactoryBot.create(:editors_group)
    FactoryBot.create(:depositors_group)

    login_as work_depositor
  end

  describe 'read permissions' do
    let!(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }

    before do
      solr = Blacklight.default_index.connection
      solr.add(work.to_solr)
      solr.commit
    end

    %w[open authenticated].each do |visibility|
      context "with #{visibility} visibility" do
        let(:work) { create(:work, visibility: visibility, admin_set_id: admin_set_id) }

        it "can see the work's public show page" do
          get hyrax_generic_work_path(work)

          expect(response).to have_http_status(:success)
        end

        it 'can see the work in search results' do
          get search_catalog_path

          expect(response).to have_http_status(:success)
          expect(response.body).to include(work.title.first)
        end
      end
    end

    context 'with restricted visibility' do
      let(:work) { create(:work, visibility: 'restricted', admin_set_id: admin_set_id) }

      it "cannot see the work's show page" do
        get hyrax_generic_work_path(work)

        expect(response).to have_http_status(:unauthorized)
      end

      it 'cannot see the work in search results' do
        get search_catalog_path

        expect(response).to have_http_status(:success)
        expect(response.body).not_to include(work.title.first)
      end
    end
  end

  describe 'create permissions' do
    let(:valid_work_params) do
      {
        generic_work: {
          title: ['Test Work'],
          creator: [work_depositor.email],
          keyword: ['asdf'],
          rights_statement: 'http://rightsstatements.org/vocab/CNE/1.0/'
        }
      }
    end

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
    let(:work) { create(:work) }

    it 'cannot edit the work' do
      get edit_hyrax_generic_work_path(work)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'destroy permissions' do
    let(:work) { create(:work) }

    it 'can edit the work' do
      delete hyrax_generic_work_path(work)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  # TODO: add approve permissions
end
