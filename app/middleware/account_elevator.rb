# Apartment middleware for switching tenants based on the
# CNAME entry for an account.
class AccountElevator < Apartment::Elevators::Generic
  # @return [String] The tenant to switch to
  def parse_tenant_name(request)
    account = Account.from_request(request)

    account.tenant if account
  end
end
