require 'rails_helper'

RSpec.describe AuthProvider, type: :model do
  subject do
    described_class.new(
      provider: 'saml',
      client_id: 'client_id',
      client_secret: 'client_secret',
      idp_sso_service_url: 'idp_sso_service_url'
    )
  end
  
  context 'attributes and validations' do
    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is not valid without a provider' do
      subject.provider = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid without a client_id' do
      subject.client_id = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid without a client_secret' do
      subject.client_secret = nil
      expect(subject).to_not be_valid 
    end
  end

  context 'transactions' do
    it 'has none to begin with' do
      expect(described_class.count).to eq 0
    end

    it 'has one after adding one' do
      AuthProvider.create(
        provider: 'saml',
        client_id: 'client_id',
        client_secret: 'client_secret',
      )
      expect(described_class.count).to eq 1
    end
  end
end
