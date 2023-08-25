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
    session['omniauth.state'] = state || SecureRandom.hex(16)
  end

  def stored_state
    Rails.logger.info("Stored State: #{session['omniauth.state']}.  Jeremy: #{session['jeremy']}.  Omniauth Other: #{session['omniauth.jeremy']}.  Caller: #{caller[0..9].map(&:to_s)}")
    session.delete('omniauth.state')
  end

  def callback_phase
    error = params['error_reason'] || params['error']
    error_description = params['error_description'] || params['error_reason']
    invalid_state = (options.require_state && params['state'].to_s.empty?) || params['state'] != stored_state

    # raise self.class::CallbackError, error: params['error'], reason: error_description, uri: params['error_uri'] if error
    # raise self.class::CallbackError, error: :csrf_detected, reason: "Invalid 'state' parameter" if invalid_state

    Rails.logger.info("@@@ Calling #{self.class}#valid_response_type? with #{params.inspect} and configured_response_type #{configured_response_type.inspect}, params.key? #{params.key?(configured_response_type).inspect}")
    return unless valid_response_type?

    Rails.logger.info("@@@ Checking issuer: options.issuer: #{options.issuer.inspect}, scheme: #{client_options.scheme.inspect}, host: #{client_options.host.inspect}, port #{client_options.port.inspect}")
    options.issuer = issuer if options.issuer.nil? || options.issuer.empty?

    Rails.logger.info("@@@ Verifying id_token")
    verify_id_token!(params['id_token']) if configured_response_type == 'id_token'

    Rails.logger.info("@@@ Performing #{self.class}#discover!")
    discover!

    Rails.logger.info("@@@ Setting redirect_uri #{redirect_uri.inspect}")
    client.redirect_uri = redirect_uri

    Rails.logger.info("@@@ configured_response_type #{configured_response_type.inspect}")
    return id_token_callback_phase if configured_response_type == 'id_token'

    Rails.logger.info("@@@ authorization_code #{authorization_code.inspect}")
    client.authorization_code = authorization_code

    Rails.logger.info("@@@ access_token #{access_token.inspect}")
    access_token

    Rails.logger.info("@@@ calling super")
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
