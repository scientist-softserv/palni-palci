# frozen_string_literal: true

RSpec.describe RedisEndpoint do
  let(:namespace) { 'foobar' }

  describe '.options' do
    subject { described_class.new(namespace:) }

    it 'uses the configured application settings' do
      expect(subject.options[:namespace]).to eq namespace
    end
  end

  describe '#ping' do
    let(:faux_redis_instance) { double(Hyrax::RedisEventStore, ping: 'PONG') }
    it 'checks if the service is up' do
      allow(subject).to receive(:redis_instance).and_return(faux_redis_instance)
      expect(subject.ping).to be_truthy
    end

    it 'is false if the service is down' do
      allow(faux_redis_instance).to receive(:ping).and_raise(RuntimeError)
      allow(subject).to receive(:redis_instance).and_return(faux_redis_instance)
      expect(subject.ping).to eq false
    end
  end
end
