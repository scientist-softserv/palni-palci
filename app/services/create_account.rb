# Initialize and configure external dependencies for an Account
class CreateAccount
  attr_reader :account, :users

  ##
  # @param [Account]
  def initialize(account, users=[])
    @account = account
    @users = users
  end

  # @return [Boolean] true if save and jobs spawning were successful
  def save
    account.save && create_external_resources ? true : false
  end

  # `Apartment::Tenant.create` calls the DB adapter's `switch`, which we have a hook into
  # via an initializer.  In our hook we do `account.switch!` and that requires a well-formed
  # Account (i.e. creation steps complete, endpoints populated).  THEREFORE, `create_tenant`
  # must be called *after* all external resources are provisioned.
  def create_external_resources
    create_account_inline && create_tenant
  end

  ##
  # Create the apartment database tenant and initialize it with seed data
  def create_tenant
    Apartment::Tenant.create(account.tenant) do
      initialize_account_data
      account.switch do
        Hyrax::GroupsService.create_default_hyrax_groups
        default = Hyrax::CollectionType.find_or_create_default_collection_type
        admin_set = Hyrax::CollectionType.find_or_create_admin_set_type
        collection_types = Hyrax::CollectionType.all
        collection_types.each do |c|
          next unless c.title =~ /^translation missing/
          oldtitle = c.title
          c.title = I18n.t(c.title.gsub("translation missing: en.", ''))
          c.save
          puts "#{oldtitle} changed to #{c.title}"
        end
        AdminSet.find_or_create_default_admin_set_id

        self.users.each do |user|
          user.add_role :admin, account.sites.first
          user.add_role :superadmin
        end

        true
      end
    end
  end

  # Sacrifing idempotency of our account creation jobs here to reflect
  # the dependency that exists between creating endpoints,
  # specifically Solr and Fedora, and creation of the default Admin Set.
  def create_account_inline
    CreateAccountInlineJob.perform_now(account)
  end

  private

    def initialize_account_data
      Site.update(account: account)
    end
end
