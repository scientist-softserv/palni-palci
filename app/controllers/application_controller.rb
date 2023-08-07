# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include HykuHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true

  force_ssl if: :ssl_configured?

  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller

  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  helper_method :current_account, :admin_host?, :home_page_theme, :show_page_theme, :search_results_theme
  helper_method :current_account, :admin_host?, :home_page_theme, :show_page_theme, :search_results_theme, :render_ocr_snippets
  before_action :authenticate_if_needed
  before_action :set_raven_context
  before_action :require_active_account!, if: :multitenant?
  before_action :set_account_specific_connections!
  before_action :elevate_single_tenant!, if: :singletenant?
  skip_after_action :discard_flash_if_xhr

  rescue_from Apartment::TenantNotFound do
    raise ActionController::RoutingError, 'Not Found'
  end

  # Override method from devise-guests v0.7.0 to prevent the application
  # from attempting to create duplicate guest users
  def guest_user
    return @guest_user if @guest_user
    if session[:guest_user_id]
      # Override - added #unscoped to include guest users who are filtered out of User queries by default
      @guest_user = User.unscoped.find_by(User.authentication_keys.first => session[:guest_user_id]) rescue nil
      @guest_user = nil if @guest_user.respond_to? :guest and !@guest_user.guest
    end
    @guest_user ||= begin
      u = create_guest_user(session[:guest_user_id])
      session[:guest_user_id] = u.send(User.authentication_keys.first)
      u
    end
    @guest_user
  end

  protected

    # remove this once we've backported to `IIIFPrintHelper` and update IIIF Print
    def render_ocr_snippets(options = {})
      snippets = options[:value]
      # rubocop:disable Rails/OutputSafety
      snippets_content = [ActionController::Base.helpers.content_tag('div',
                                                                     "... #{snippets.first} ...".html_safe,
                                                                     class: 'ocr_snippet first_snippet')]
      # rubocop:enable Rails/OutputSafety
      if snippets.length > 1
        snippets_content << render(partial: 'catalog/snippets_more',
                                   locals: { snippets: snippets.drop(1),
                                             options: options })
      end
      # rubocop:disable Rails/OutputSafety
      snippets_content.join("\n").html_safe
      # rubocop:enable Rails/OutputSafety
    end

    def is_hidden
      current_account.persisted? && !current_account.is_public?
    end

    def is_api_or_pdf
      request.format.to_s.match('json') ||
        params[:print] ||
        request.path.include?('api') ||
        request.path.include?('pdf')
    end

    def is_staging
      ['staging'].include?(Rails.env)
    end

    ##
    # Extra authentication for palni-palci during development phase
    def authenticate_if_needed
      # Disable this extra authentication in test mode
      return true if Rails.env.test?
      if (is_hidden || is_staging) && !is_api_or_pdf
        authenticate_or_request_with_http_basic do |username, password|
          username == "samvera" && password == "hyku"
        end
      end
    end

    def super_and_current_users
      users = Role.find_by(name: 'superadmin')&.users.to_a
      users << current_user if current_user && !users.include?(current_user)
      users
    end

    ##
    # Provides the prepare_for_conditional_work_authorization! (see #authenticate_if_needed)
    include WorkAuthorization::StoreUrlForScope

    ##
    # Extra authentication for palni-palci during development phase
    def authenticate_if_needed
      # Disable this extra authentication in test mode
      return true if Rails.env.test?
      if (is_hidden || is_staging) && !is_api_or_pdf
        # Why capture this?  In my review of the params and scope for authorization, I had a blank
        # value in some of the OmniAuth instantiations.
        prepare_for_conditional_work_authorization!(request.original_url)
        authenticate_or_request_with_http_basic do |username, password|
          username == "pals" && password == "pals"
        end
      end
    end

    def set_raven_context
      Raven.user_context(id: session[:current_user_id]) # or anything else in session
      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    end

    def require_active_account!
      return if singletenant?
      return if devise_controller?
      raise Apartment::TenantNotFound, "No tenant for #{request.host}" unless current_account.persisted?
    end

    def set_account_specific_connections!
      current_account&.switch!
    end

    def multitenant?
      @multitenant ||= ActiveModel::Type::Boolean.new.cast(ENV.fetch('HYKU_MULTITENANT', false))
    end

    def singletenant?
      !multitenant?
    end

    def elevate_single_tenant!
      AccountElevator.switch!(current_account.cname) if current_account && root_host?
    end

    def root_host?
      Account.canonical_cname(request.host) == Account.root_host
    end

    def admin_host?
      return false if singletenant?
      Account.canonical_cname(request.host) == Account.admin_host
    end

    def current_account
      @current_account ||= Account.from_request(request)
      @current_account ||= if multitenant?
                             Account.new do |a|
                               a.build_solr_endpoint
                               a.build_fcrepo_endpoint
                               a.build_redis_endpoint
                             end
                           else
                             Account.single_tenant_default
                           end
    end

    # Find themes set on Site model, or return default
    def home_page_theme
      current_account.sites&.first&.home_theme || 'default_home'
    end

    def show_page_theme
      current_account.sites&.first&.show_theme || 'default_show'
    end

    def search_results_theme
      current_account.sites&.first&.search_theme || 'list_view'
    end

    # Add context information to the lograge entries
    def append_info_to_payload(payload)
      super
      payload[:request_id] = request.uuid
      payload[:user_id] = current_user.id if current_user
      payload[:account_id] = current_account.cname if current_account
    end

    def ssl_configured?
      ActiveRecord::Type::Boolean.new.cast(current_account.ssl_configured)
    end

    # Overrides method in devise-guest gem
    # https://github.com/cbeer/devise-guests/pull/28
    # fixes issue with cross process conflicts in guest users
    # uses uuid for uniqueness rather than timestamp
    # TODO: remove method when devise-guest gem is updated
    def guest_email_authentication_key key
      key &&= nil unless key.to_s.match(/^guest/)
      key ||= "guest_" + SecureRandom.uuid + "@example.com"
    end
end
