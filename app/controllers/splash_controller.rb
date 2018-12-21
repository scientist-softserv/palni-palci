class SplashController < ProprietorController
  def index
    @accounts = Account.all
    @images = @accounts.map do |account|
      Apartment::Tenant.switch(account.tenant) do
        Site.instance&.logo_image&.url(:medium) || "https://via.placeholder.com/400?text=#{account.cname}"
      end
    end
  end
end
