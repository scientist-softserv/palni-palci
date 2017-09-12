class AccountSignUpController < ProprietorController
  load_and_authorize_resource instance_name: :account, class: 'Account'

  before_action :ensure_admin!, if: :admin_only_tenant_creation?

  # GET /account/sign_up
  def new
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb 'New account', new_sign_up_path
  end

  # POST /account/sign_up
  # POST /account/sign_up.json
  def create
    respond_to do |format|
      if CreateAccount.new(@account).save
        format.html { redirect_to first_user_registration_url, notice: 'Account was successfully created.' }
        format.json { render :show, status: :created, location: @account.cname }
      else
        format.html { render :new }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def ensure_admin!
      # Require Admin access to perform any actions
      authorize! :read, :admin_dashboard
    end

    def admin_only_tenant_creation?
      Settings.multitenancy.admin_only_tenant_creation
    end

    def first_user_registration_url
      new_user_registration_url(host: @account.cname)
    end

    def create_params
      params.require(:account).permit(:name)
    end
end
