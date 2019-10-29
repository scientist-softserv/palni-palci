RSpec.describe Admin::GroupsController, singletenant: true do
  xcontext 'as an anonymous user' do
    # skip this
    describe 'GET #index' do
      subject { get :index }

      it { is_expected.to redirect_to root_path }
    end
  end

  context 'as an admin user' do
    before { sign_in create(:admin) }

    xdescribe 'GET #index' do
      # skip these
      subject { get :index }

      it { is_expected.to render_template('layouts/hyrax/dashboard') }
      it { is_expected.to render_template('admin/groups/index') }
    end

    describe 'GET #new' do
      subject { get :new }

      skip { is_expected.to render_template('admin/groups/new') }
    end

    describe 'POST #create' do
      it 'creates a group when it recieves valid attribtes' do
        skip
        expect do
          post :create, params: { hyku_group: FactoryBot.attributes_for(:group) }
        end.to change(Hyku::Group, :count).by(1)
      end
    end

    context 'with an existing group' do
      let(:group) { FactoryBot.create(:group) }
      let(:new_attributes) { FactoryBot.attributes_for(:group) }

      describe 'GET #edit' do
        subject { get :edit, params: { id: group.id } }

        skip { is_expected.to render_template('admin/groups/edit') }
      end

      describe 'PATCH #update' do
        subject { Hyku::Group.find_by(id: group.id) }

        before { patch :update, params: { id: group.id, hyku_group: new_attributes } }

        skip 'updates attribtes' do
          expect(subject.name).to eq(new_attributes.fetch(:name))
          expect(subject.description).to eq(new_attributes.fetch(:description))
        end
      end

      describe 'GET #remove' do
        subject { get :remove, params: { id: group.id } }

        skip { is_expected.to render_template('admin/groups/remove') }
      end

      describe 'DELETE #destroy' do
        subject { Hyku::Group.find_by(id: group.id) }

        before { delete :destroy, params: { id: group.id } }

        skip { is_expected.to be_nil }
      end
    end
  end
end
