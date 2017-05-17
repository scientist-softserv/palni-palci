class CreateAccountInlineJob < ActiveJob::Base
  non_tenant_job

  def perform(account)
    CreateSolrCollectionJob.perform_now(account)
    CreateFcrepoEndpointJob.perform_now(account)
    CreateRedisNamespaceJob.perform_now(account)
    # CreateDefaultAdminSetJob.perform_now(account) # handled in Apartment callback
  end
end
