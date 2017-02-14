RSpec.describe 'admin/groups/users', type: :view do
  context 'groups index page' do
    let(:group) { FactoryGirl.create(:group) }
    let(:user_1) { FactoryGirl.create(:user) }
    let(:user_2) { FactoryGirl.create(:user) }
    let(:users) { double('users') }
    let(:path_parameters) do
      {
        controller: 'admin/group_users',
        action: 'index',
        group_id: group.id
      }
    end

    before do
      allow(controller).to receive(:params).and_return(path_parameters)
      # Mocking methods required by UrlFor in order to pass in a :group_id
      allow(controller.request).to receive(:params).and_return(path_parameters)
      allow(controller.request).to receive(:path_parameters).and_return(path_parameters)
      # Mocking users collection to provide methods for kaminari
      allow(users).to receive(:each).and_yield(user_1).and_yield(user_2)
      allow(users).to receive(:total_pages).and_return(1)
      allow(users).to receive(:current_page).and_return(1)
      allow(users).to receive(:limit_value).and_return(10)
      assign(:users, users)
      assign(:group, group)
      render
    end

    it 'has the "users" tab in an active state' do
      expect(rendered).to have_selector('.nav-tabs .active a', text: 'Users')
    end

    it 'has tabs for other actions on the group' do
      expect(rendered).to have_selector('.nav-tabs li a', text: 'Description')
      expect(rendered).to have_selector('.nav-tabs li a', text: 'Remove')
    end

    it 'has a user search control' do
      expect(rendered).to have_selector('form', class: 'js-group-user-search')
      expect(rendered).to have_selector('input', class: 'js-group-user-search__query')
      expect(rendered).to have_selector('input', class: 'js-group-user-search__submit')
    end

    it 'has an add user form' do
      expect(rendered).to have_selector('form', class: 'js-group-user-add')
      expect(rendered).to have_selector('input', class: 'js-group-user-add__id')
      expect(rendered).to have_selector('input', class: 'js-group-user-add__submit')
    end

    it 'has a member search control' do
      expect(rendered).to have_selector('input', class: 'list-scope__query')
      expect(rendered).to have_selector('input', class: 'list-scope__submit')
    end

    it 'has a pagination select control' do
      expect(rendered).to have_selector('form', class: 'js-per-page')
      expect(rendered).to have_selector('select', class: 'js-per-page__select')
      expect(rendered).to have_selector('input', class: 'js-per-page__submit')
    end

    it 'renders a list of members' do
      expect(rendered).to have_selector('td', text: user_1.name)
      expect(rendered).to have_selector('td', text: user_2.name)
    end
  end
end
