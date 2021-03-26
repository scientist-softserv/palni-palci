# frozen_string_literal: true

RSpec.describe "User roles", type: :request, clean: true, multitenant: true do
  let(:account) { create(:account) }
  let(:tenant_user_attributes) { attributes_for(:user) }

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

  # try to go to the user index url's with certain roles. no permission: 302. 200 == success. cmk + k to clear and look at logs

end
