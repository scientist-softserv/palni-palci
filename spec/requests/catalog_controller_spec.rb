# frozen_string_literal: true

require "spec_helper"

RSpec.describe CatalogController, type: :request, multitenant: true do
  let(:user) { create(:user, email: 'test_user@repo-sample.edu') }
  let(:work) { build(:work, title: ['welcome test'], id: SecureRandom.uuid, user: user) }
  let(:hyku_sample_work) { build(:work, title: ['sample test'], id: SecureRandom.uuid, user: user) }
  let(:sample_solr_connection) { RSolr.connect url: "#{ENV['SOLR_URL']}hydra-sample" }

  let(:cross_search_solr) { create(:solr_endpoint, url: "#{ENV['SOLR_URL']}hydra-cross-search-tenant") }
  let!(:cross_search_tenant_account) do
    create(:account,
           name: 'cross_search',
           cname: 'example.com',
           solr_endpoint: cross_search_solr,
           fcrepo_endpoint: nil)
  end

  before do
    WebMock.disable!
    allow(AccountElevator).to receive(:switch!).with(cross_search_tenant_account.cname).and_return('public')
    allow(Apartment::Tenant.adapter).to receive(:connect_to_new).and_return('')
    ActiveFedora::SolrService.instance.conn = sample_solr_connection
    ActiveFedora::SolrService.add(hyku_sample_work.to_solr)
    ActiveFedora::SolrService.commit

    ActiveFedora::SolrService.reset!
    ActiveFedora::SolrService.add(work.to_solr)
    ActiveFedora::SolrService.commit
  end

  after do
    WebMock.enable!

    ActiveFedora::SolrService.instance.conn = sample_solr_connection
    ActiveFedora::SolrService.delete(hyku_sample_work.id)
    ActiveFedora::SolrService.commit

    ActiveFedora::SolrService.reset!
    ActiveFedora::SolrService.delete(work.id)
    ActiveFedora::SolrService.commit
  end

  describe 'Cross Tenant Search' do
    let(:cross_tenant_solr_options) do
      {
        "read_timeout" => 120,
        "open_timeout" => 120,
        "url" => "#{ENV['SOLR_URL']}hydra-cross-search-tenant",
        "adapter" => "solr"
      }
    end

    let(:black_light_config) { Blacklight::Configuration.new(connection_config: cross_tenant_solr_options) }

    before do
      host! "http://#{cross_search_tenant_account.cname}/"
    end

    context 'can fetch data from other tenants' do
      it 'cross-search-tenant can fetch all record in child tenants' do
        connection = RSolr.connect(url: "#{ENV['SOLR_URL']}hydra-cross-search-tenant")
        allow_any_instance_of(Blacklight::Solr::Repository).to receive(:build_connection).and_return(connection)
        allow(CatalogController).to receive(:blacklight_config).and_return(black_light_config)
        # make sure the blacklight config knows the app uses advanced search
        black_light_config.advanced_search = {}
        get "http://#{cross_search_tenant_account&.cname}/catalog?q=test"
        expect(response.status).to eq(200)
      end
    end
  end
end
