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
  before_action :authenticate_if_needed
  before_action :set_raven_context
  before_action :require_active_account!, if: :multitenant?
  before_action :set_account_specific_connections!
  before_action :elevate_single_tenant!, if: :singletenant?
  skip_after_action :discard_flash_if_xhr

  rescue_from Apartment::TenantNotFound do
    raise ActionController::RoutingError, 'Not Found'
  end

  after_action :store_action

  def store_action
    return unless request.get?
    if (request.path != "/single_signon" &&
      request.path != "/users/sign_in" &&
      request.path != "/users/sign_up" &&
      request.path != "/users/password/new" &&
      request.path != "/users/password/edit" &&
      request.path != "/users/confirmation" &&
      request.path != "/users/sign_out" &&
      !request.xhr?) # don't store ajax calls
      store_location_for(:user, request.fullpath)
    end
  end

  around_action :global_request_logging
  def global_request_logging
    rl = ActiveSupport::Logger.new('log/request.log')
    if request.host&.match('blc.hykucommons')
      http_request_header_keys = request.headers.env.keys.select{|header_name| header_name.match("^HTTP.*|^X-User.*")}
      http_request_headers = request.headers.env.select{|header_name, header_value| http_request_header_keys.index(header_name)}

      rl.error '*' * 40
      rl.error request.method
      rl.error request.url
      rl.error request.remote_ip
      rl.error ActionController::HttpAuthentication::Token.token_and_options(request)

      cookies[:time] = Time.now.to_s
      session[:time] = Time.now.to_s
      http_request_header_keys.each do |key|
        rl.error ["%20s" % key.to_s, ':', request.headers[key].inspect].join(" ")
      end
      rl.error '-' * 40 + ' params'
      params.keys.each do |key|
        rl.error ["%20s" % key.to_s, ':', params[key].inspect].join(" ")
      end
      rl.error '-' * 40 + ' cookies'
      cookies.to_h.keys.each do |key|
        rl.error ["%20s" % key.to_s, ':', cookies[key].inspect].join(" ")
      end
      rl.error '-' * 40 + ' session'
      session.to_h.keys.each do |key|
        rl.error ["%20s" % key.to_s, ':', session[key].inspect].join(" ")
      end

      rl.error '*' * 40
    end
    begin
      yield
    ensure
      rl.error response.body
    end
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

    def super_and_current_users
      users = Role.find_by(name: 'superadmin')&.users.to_a
      users << current_user if current_user && !users.include?(current_user)
      users
    end

    ##
    # Extra authentication for palni-palci during development phase
    def authenticate_if_needed
      # Disable this extra authentication in test mode
      return true if Rails.env.test?
      if (is_hidden || is_staging) && !is_api_or_pdf
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

    ##
    # OVERRIDE Hyrax::Controller#deny_access_for_anonymous_user
    #
    # We are trying to serve two types of users:
    #
    # - Admins
    # - Not-admins
    #
    # Given that admins are a small subset, we can train and document how they can sign in.  In other
    # words, favor workflows that impact the less trained folk to help them accomplish their tasks.
    #
    # Without this change, given the site had an SSO provider, when I (an unauthenticated user) went
    # to a private work, then it would redirect me to the `/user/sign_in` route.
    #
    # At that route I had the following option:
    #
    # 1. Providing a username and password
    # 2. Selecting one of the SSO providers to use for sign-in.
    #
    # The problem with this behavior was that a user who was given a Controlled Digital Lending (CDL)
    # URL would see a username/password and likely attempt to authenticate with their CDL
    # username/password (which was managed by the SSO provider).
    #
    # The end result is that the authentication page most likely would create confusion.
    #
    # With this function change, I'm setting things up such that when the application uses calls
    # `new_user_session_path` we make a decision on what URL to resolve.
    def deny_access_for_anonymous_user(exception, json_message)
      session['user_return_to'] = request.url
      respond_to do |wants|
        wants.html do
          # See ./app/views/single_signon/index.html.erb for our 1 provider logic.
          path = if IdentityProvider.exists?
                   main_app.single_signon_index_path
                 else
                   main_app.new_user_session_path
                 end
          redirect_to path, alert: exception.message
        end
        wants.json { render_json_response(response_type: :unauthorized, message: json_message) }
      end
    end
end
