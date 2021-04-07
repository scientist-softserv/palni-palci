# frozen_string_literal: true

RSpec.describe "User roles", type: :request, clean: true, multitenant: true do
  let(:account) { create(:account) }
  let(:tenant_user_attributes) { attributes_for(:user) }

  context 'within a tenant' do

    before do
      WebMock.disable!
      Apartment::Tenant.create(account.tenant)
      Apartment::Tenant.switch(account.tenant) do
        Site.update(account: account)
      end
    end
  
    after do
      WebMock.enable!
      Apartment::Tenant.drop(account.tenant)
    end

    context 'a registered user' do
      let(:user) { FactoryBot.create(:user) }

      before do
        login_as(user)
      end
  
      it 'can access the users profile' do
        get "http://#{account.cname}/dashboard/profiles/#{user.email.gsub('.', '-dot-')}"
        expect(response.status).to eq(200)
        expect(response).to have_http_status(:success)
      end

      it 'can access the users notifications' do
        get "http://#{account.cname}/notifications"
        expect(response.status).to eq(200)
        expect(response).to have_http_status(:success)
      end

      it 'can access the users transfers' do
        get "http://#{account.cname}/dashboard/transfers"
        expect(response.status).to eq(200)
        expect(response).to have_http_status(:success)
      end

      it 'can access the users manage proxies' do
        get "http://#{account.cname}/proxies"
        expect(response.status).to eq(200)
        expect(response).to have_http_status(:success)
      end
    end

    context 'an unregistered user' do

      let(:user_params) do 
        { 
          user: {
            email: tenant_user_attributes[:email],
            password: tenant_user_attributes[:password],
            password_confirmation: tenant_user_attributes[:password]
          }
        }
      end

      it 'can sign up' do
        expect { post "http://#{account.cname}/users", params: user_params }
          .to change(User, :count).by(1)
        expect(response.status).to eq(302)
        expect(response).to have_http_status(:redirect)
      end
    end

  end

  context 'a superadmin user' do
    let(:superadmin) { FactoryBot.create(:superadmin) }

    before do
      login_as(superadmin, scope: :user)
    end

    it 'can access the users index' do
      get proprietor_users_url
      expect(response.status).to eq(200)
      expect(response).to have_http_status(:success)
    end
  end

  context 'a registered user with user_admin role' do
    let(:user_admin) { FactoryBot.create(:user_admin) }

    before do
      login_as(user_admin, scope: :user)
    end

    it 'can access the users index' do
      get proprietor_users_url
      expect(response.status).to eq(200)
      expect(response).to have_http_status(:success)
    end
  end

  context 'a registered user with user_manager role' do
    let(:user_manager) { FactoryBot.create(:user_manager) }

    before do
      login_as(user_manager, scope: :user)
    end

    it 'can access the users index' do
      get proprietor_users_url
      expect(response.status).to eq(200)
      expect(response).to have_http_status(:success)
    end
  end

  context 'a registered user with user_reader role' do
    let(:user_reader) { FactoryBot.create(:user_reader) }

    before do
      login_as(user_reader, scope: :user)
    end

    it 'can access the users index' do
      get proprietor_users_url
      expect(response.status).to eq(200)
      expect(response).to have_http_status(:success)
    end
  end

  context 'a registered user with no role' do
    let(:user) { FactoryBot.create(:user) }

    before do
      login_as(user, scope: :user)
    end

    it 'cannot access the users index' do
      get proprietor_users_url
      expect(response.status).to eq(302)
      expect(response).to have_http_status(:redirect)
    end
  end

end
