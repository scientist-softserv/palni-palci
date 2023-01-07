# frozen_string_literal: true

# https://github.com/heartcombo/devise/wiki/How-To:-Use-custom-mailer
# Provides a default host for the current tenant
class HykuMailer < Devise::Mailer
  def default_url_options
    { host: host_for_tenant }
  end

  private

    def host_for_tenant
      Account.find_by(tenant: Apartment::Tenant.current)&.cname || Account.admin_host
    end
end
