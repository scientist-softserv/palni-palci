RSpec.describe 'Accounts administration', multitenant: true do
  context 'as an superadmin' do
    let(:user) { FactoryGirl.create(:superadmin) }
    let(:account) do
      FactoryGirl.create(:account, solr_endpoint_attributes: { url: 'http://localhost:8080/solr' },
                                   fcrepo_endpoint_attributes: { url: 'http://localhost:8080/fcrepo' })
    end

    before do
      login_as(user, scope: :user)
      Capybara.default_host = "http://#{Account.admin_host}"
      allow(Apartment::Tenant).to receive(:switch).with(account.tenant) do |&block|
        block.call
      end
    end

    it 'changes the associated cname' do
      visit edit_proprietor_account_path(account)

      fill_in 'Tenant CNAME', with: 'example.com'

      click_on 'Save'

      account.reload

      expect(account.cname).to eq 'example.com'
    end

    it 'changes the account service endpoints' do
      visit edit_proprietor_account_path(account)

      fill_in 'account_solr_endpoint_attributes_url', with: 'http://example.com/solr/'
      fill_in 'account_fcrepo_endpoint_attributes_url', with: 'http://example.com/fcrepo'
      fill_in 'account_fcrepo_endpoint_attributes_base_path', with: '/dev'

      click_on 'Save'

      account.reload

      expect(account.solr_endpoint.url).to eq 'http://example.com/solr/'
      expect(account.fcrepo_endpoint.url).to eq 'http://example.com/fcrepo'
      expect(account.fcrepo_endpoint.base_path).to eq '/dev'
    end
  end
end
