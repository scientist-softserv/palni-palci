# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/MultipleDescribes
RSpec.describe OmniAuth::Strategies::OpenIDConnectDecorator do
  let(:strategy) do
    Class.new do
      def initialize(options: {}, session: {})
        @options = options
        @session = session
      end
      attr_reader :options, :session

      # Include this after the attr_reader :options to leverage super method
      prepend OmniAuth::Strategies::OpenIDConnectDecorator
    end
  end

  let(:requested_work_url) { "https://hello.world/something-special" }
  let(:options) { { scope: [:openid] } }
  let(:session) { { "cdl.requested_work_url" => requested_work_url } }
  let(:instance) { strategy.new(options: options, session: session) }

  describe '#options' do
    subject { instance.options }

    it "has a :scope key that appends the #requested_work_url" do
      expect(subject.fetch(:scope)).to match_array([:openid, requested_work_url])
    end
  end

  describe '#requested_work_url' do
    subject { instance.requested_work_url }

    it "fetches the 'cdl.requested_work_url' session" do
      expect(subject).to eq(requested_work_url)
    end

    describe "when the 'cdl.requested_work_url' key is missing" do
      let(:session) { {} }

      it { is_expected.to be_nil }
    end
  end
end

RSpec.describe OmniAuth::Strategies::OpenIDConnect do
  describe '#options method' do
    subject(:options_method) { described_class.instance_method(:options) }

    context 'source_location' do
      subject { options_method.source_location }

      it { is_expected.to match_array([Rails.root.join('lib', 'omni_auth', 'strategies', 'open_id_connect_decorator.rb').to_s, Integer]) }
    end

    context 'super_method' do
      subject { options_method.super_method }

      it { is_expected.not_to be_nil }
    end
  end
end
# rubocop:enable RSpec/MultipleDescribes
