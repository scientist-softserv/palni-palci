module OmniAuth::Strategies::OpenIDConnectDecorator
  ##
  # OVERRIDE: Per the client's design consideration, we need to provide, as part of the scope, the
  # URL of the work that the user wants to access.  Presently we have hard-coded, in the identity
  # provider configuration, a single work URL to which we have access.  However, that needs to be
  # dynamic going forward.  The hope was that the HTTP_REFERER would be adequate, but by the type
  # we're processing this, that REFERRER is not the URL of the work but instead the following:
  #
  #   https://Freshare.commons-archive.org/single_signon?locale=en
  #
  # We may need to store the value in a session and make sure to remove query parameters.
  # Also, if the scope is wrong we get back:
  #
  # "Failed to get response from patron API" with 200 status!
  #
  # Rename to options to override the default options specified.
  def options_stuff
    opts = super
    opts[:scope] = [
      :openid,
      "https://reshare.palni-palci-staging.notch8.cloud/concern/cdls/74ebfc53-ee7c-4dc9-9dd7-693e4d840745",
      env['HTTP_REFERER']
    ]
  end

  def new_state
    state = if options.state.respond_to?(:call)
              if options.state.arity == 1
                options.state.call(env)
              else
                options.state.call
              end
            end
    Rails.logger.error("New State: called state: #{state.inspect}.")
    session['omniauth.state'] = state || SecureRandom.hex(16)
  end

  def stored_state
    Rails.logger.error("Stored State: #{session['omniauth.state']}.  Jeremy: #{session['jeremy']}.  Omniauth Other: #{session['omniauth.jeremy']}.  Caller: #{caller[0..9].map(&:to_s)}")
    session.delete('omniauth.state')
  end

  def callback_phase
    error = params['error_reason'] || params['error']
    error_description = params['error_description'] || params['error_reason']
    Rails.logger.error("REQUIRE_STATE: #{options.require_state.inspect}; PARAMS['state'] #{params['state'].inspect}")
    invalid_state = (options.require_state && params['state'].to_s.empty?) || (options.require_state && params['state'] != stored_state)

    raise self.class::CallbackError, error: params['error'], reason: error_description, uri: params['error_uri'] if error
    raise self.class::CallbackError, error: :csrf_detected, reason: "Invalid 'state' parameter" if invalid_state

    return unless valid_response_type?

    options.issuer = issuer if options.issuer.nil? || options.issuer.empty?

    verify_id_token!(params['id_token']) if configured_response_type == 'id_token'
    discover!
    client.redirect_uri = redirect_uri

    return id_token_callback_phase if configured_response_type == 'id_token'

    client.authorization_code = authorization_code
    access_token
    super
  rescue self.class::CallbackError => e
    fail!(e.error, e)
  rescue ::Rack::OAuth2::Client::Error => e
    fail!(e.response[:error], e)
  rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
    fail!(:timeout, e)
  rescue ::SocketError => e
    fail!(:failed_to_connect, e)
  end
end

OmniAuth::Strategies::OpenIDConnect.prepend(OmniAuth::Strategies::OpenIDConnectDecorator)
