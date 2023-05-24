FactoryBot.define do
  factory :auth_provider do
    { provider: 'saml' }
    { client_id: 'client_id' }
    { client_secret: 'client_secret' }
    { idp_sso_service_url: 'idp_sso_service_url' }
  end
end