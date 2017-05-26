class CreateFcrepoEndpointJob < ActiveJob::Base
  non_tenant_job

  def perform(account)
    name = account.tenant.parameterize

    account.create_fcrepo_endpoint(base_path: "/#{name}")
  end
end
