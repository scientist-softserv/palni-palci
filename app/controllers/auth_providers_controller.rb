class AuthProvidersController < ApplicationController
  layout 'hyrax/dashboard'

  before_action :set_site
  before_action :ensure_admin!
  before_action :set_auth_provider, only: %i[ show edit update destroy ]

  # TODO: remove index, show, new and create actions
  # TODO: remove destroy?
  # GET /auth_providers or /auth_providers.json
  def index
    @auth_providers = AuthProvider.all
  end

  # GET /auth_providers/1 or /auth_providers/1.json
  def show
  end

  # GET /auth_providers/new
  def new
    @auth_provider = AuthProvider.new
  end

  # GET /auth_providers/1/edit
  def edit
  end

  # POST /auth_providers or /auth_providers.json
  def create
    @auth_provider = AuthProvider.new(auth_provider_params)

    respond_to do |format|
      if @auth_provider.save
        format.html { redirect_to auth_provider_url(@auth_provider), notice: "Auth provider was successfully created." }
        format.json { render :show, status: :created, location: @auth_provider }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @auth_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /auth_providers/1 or /auth_providers/1.json
  def update
    respond_to do |format|
      if @auth_provider.update(auth_provider_params)
        format.html { redirect_to auth_provider_url(@auth_provider), notice: "Auth provider was successfully updated." }
        format.json { render :show, status: :ok, location: @auth_provider }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @auth_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /auth_providers/1 or /auth_providers/1.json
  def destroy
    @auth_provider.destroy

    respond_to do |format|
      format.html { redirect_to auth_providers_url, notice: "Auth provider was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_auth_provider
      @auth_provider = AuthProvider.find(params[:id])
    end
    # TODO: should this be account or site?
    def set_site
      @site ||= Site.first
    end

    def ensure_admin!
      authorize! :read, :admin_dashboard
    end

    # Only allow a list of trusted parameters through.
    def auth_provider_params
      params.require(:auth_provider).permit(:provider, :idp_sso_service_url, :client_id, :client_secret, :account_id)
    end
end
