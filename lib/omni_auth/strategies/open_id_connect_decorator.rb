module OmniAuth
  module Strategies
    ##
    # OVERRIDE to provide openid {#scope} based on the current session.
    #
    # @see https://github.com/scientist-softserv/palni-palci/issues/633
    module OpenIDConnectDecorator
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
        Rails.logger.info("=@=@=@=@ #{self.class}#session['#{WorkAuthorization::StoreUrlForScope::CDL_SESSION_KEY}'] is #{session[WorkAuthorization::StoreUrlForScope::CDL_SESSION_KEY].inspect}")
        Rails.logger.info("=@=@=@=@ #{self.class}#params['scope'] is #{params['scope'].inspect}")
        session[WorkAuthorization::StoreUrlForScope::CDL_SESSION_KEY] ||
          WorkAuthorization.url_from(scope: params['scope'])
      end
    end
  end
end

OmniAuth::Strategies::OpenIDConnect.prepend(OmniAuth::Strategies::OpenIDConnectDecorator)
