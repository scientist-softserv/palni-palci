RSpec.describe CreateFcrepoEndpointJob do
  let(:account) { FactoryGirl.create(:account) }

  it 'sets the base path configuration for fcrepo' do
    described_class.perform_now(account)

    expect(account.fcrepo_endpoint.base_path).to eq "/#{account.tenant}"
  end
end
