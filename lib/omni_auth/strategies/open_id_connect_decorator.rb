module OmniAuth
  module Strategies
    ##
    # OVERRIDE to provide openid {#scope} based on the current session.
    #
    # @see https://github.com/scientist-softserv/palni-palci/issues/633
    module OpenIDConnectDecorator
      ##
      # override callback phase to fix issue where state is not required.
      # if require_state is false, it doesn't matter what is in the state param
      def callback_phase
        error = params['error_reason'] || params['error']
        error_description = params['error_description'] || params['error_reason']
        invalid_state = false unless options.require_state
        invalid_state = true if invalid_state.nil? && params['state'].to_s.empty?
        invalid_state = params['state'] != stored_state if invalid_state.nil?

        raise OmniAuth::Strategies::OpenIDConnect::CallbackError, error: params['error'], reason: error_description, uri: params['error_uri'] if error
        raise OmniAuth::Strategies::OpenIDConnect::CallbackError, error: :csrf_detected, reason: "Invalid 'state' parameter" if invalid_state

        return unless valid_response_type?

        options.issuer = issuer if options.issuer.blank?

        verify_id_token!(params['id_token']) if configured_response_type == 'id_token'
        discover!
        client.redirect_uri = redirect_uri

        return id_token_callback_phase if configured_response_type == 'id_token'

        client.authorization_code = authorization_code
        access_token
        super
      rescue OmniAuth::Strategies::OpenIDConnect::CallbackError => e
        fail!(e.error, e)
      rescue ::Rack::OAuth2::Client::Error => e
        fail!(e.response[:error], e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
        fail!(:timeout, e)
      rescue ::SocketError => e
        fail!(:failed_to_connect, e)
      end

      ##
      # In OmniAuth, the options are a tenant wide configuration.  However, per
      # the client's controlled digitial lending (CDL) system, in the options we
      # use for authentication we must inclue the URL of the work that the
      # authenticating user wants to access.
      #
      # @note In testing, when the scope did not include the sample noted in the
      #       {#requested_work_url} method, the openid provider would return the
      #       status 200 (e.g. Success) and a body "Failed to get response from
      #       patron API"
      #
      # @return [Hash<Symbol,Object>]
      def options
        # If we don't include this, we keep adding to the `options[:scope]`
        return @decorated_options if defined? @decorated_options

        opts = super

        url = requested_work_url
        opts[:scope] += [url] if url.present? && !opts[:scope].include?(url)

        Rails.logger.info("=@=@=@=@ #{self.class}#options scope value is #{opts[:scope].inspect}")

        @decorated_options = opts
      end

      ##
      # @return [String] The URL of the work that was requested by the
      #         authenticating user.
      #
      # @note {#session} method is `@env['rack.session']`
      # @note {#env} method is the hash representation of the Rack environment.
      # @note {#request} method is the {#env} as a Rack::Request object
      #
      # @note The following URL is known to be acceptable for the reshare.commons-archive.org tenant:
      #
      #       https://reshare.palni-palci-staging.notch8.cloud/concern/cdls/74ebfc53-ee7c-4dc9-9dd7-693e4d840745
      def requested_work_url
        cdl_key = WorkAuthorization::StoreUrlForScope::CDL_SESSION_KEY
        Rails.logger.info("=@=@=@=@ #{self.class}#session['#{cdl_key}'] is #{session[cdl_key].inspect}")
        Rails.logger.info("=@=@=@=@ #{self.class}#params['scope'] is #{params['scope'].inspect}")
        session[WorkAuthorization::StoreUrlForScope::CDL_SESSION_KEY] ||
          WorkAuthorization.url_from(scope: params['scope'], request: request)
      end
    end
  end
end

OmniAuth::Strategies::OpenIDConnect.prepend(OmniAuth::Strategies::OpenIDConnectDecorator)
