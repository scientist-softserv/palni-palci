# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  # Devise will use the `secret_key_base` on Rails 4+ applications as its `secret_key`
  # by default. You can change it below and use your own secret key.
  # config.secret_key = '1b68dde35187b5e14ff257b8c7250eb6727cd42d87a4deafdaa4255b47e19a3da33aef3e5fc70c7cbf0de859b5dd417d0790c5b2860e6139ff5c6526b98db89c'

  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class
  # with default "from" parameter.
  config.mailer_sender = ENV.fetch('HYKU_CONTACT_EMAIL', 'changeme@example.com')

  # Configure the class responsible to send e-mails.
  # config.mailer = 'Devise::Mailer'

  # Configure the parent class responsible to send e-mails.
  config.parent_mailer = 'HykuMailer'

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'devise/orm/active_record'

  # ==> Configuration for any authentication mechanism
  # Configure which keys are used when authenticating a user. The default is
  # just :email. You can configure it to use [:username, :subdomain], so for
  # authenticating a user, both parameters are required. Remember that those
  # parameters are used only when authenticating and not when retrieving from
  # session. If you need permissions, you should implement that in a before filter.
  # You can also supply a hash where the value is a boolean determining whether
  # or not authentication should be aborted when the value is not present.
  # config.authentication_keys = [:email]

  # Configure parameters from the request object used for authentication. Each entry
  # given should be a request method and it will automatically be passed to the
  # find_for_authentication method and considered in your model lookup. For instance,
  # if you set :request_keys to [:subdomain], :subdomain will be used on authentication.
  # The same considerations mentioned for authentication_keys also apply to request_keys.
  # config.request_keys = []

  # Configure which authentication keys should be case-insensitive.
  # These keys will be downcased upon creating or modifying a user and when used
  # to authenticate or find a user. Default is :email.
  config.case_insensitive_keys = [:email]

  # Configure which authentication keys should have whitespace stripped.
  # These keys will have whitespace before and after removed upon creating or
  # modifying a user and when used to authenticate or find a user. Default is :email.
  config.strip_whitespace_keys = [:email]

  # Tell if authentication through request.params is enabled. True by default.
  # It can be set to an array that will enable params authentication only for the
  # given strategies, for example, `config.params_authenticatable = [:database]` will
  # enable it only for database (email + password) authentication.
  # config.params_authenticatable = true

  # Tell if authentication through HTTP Auth is enabled. False by default.
  # It can be set to an array that will enable http authentication only for the
  # given strategies, for example, `config.http_authenticatable = [:database]` will
  # enable it only for database authentication. The supported strategies are:
  # :database      = Support basic authentication with authentication key + password
  # config.http_authenticatable = false

  # If 401 status code should be returned for AJAX requests. True by default.
  # config.http_authenticatable_on_xhr = true

  # The realm used in Http Basic Authentication. 'Application' by default.
  # config.http_authentication_realm = 'Application'

  # It will change confirmation, password recovery and other workflows
  # to behave the same regardless if the e-mail provided was right or wrong.
  # Does not affect registerable.
  # config.paranoid = true

  # By default Devise will store the user in session. You can skip storage for
  # particular strategies by setting this option.
  # Notice that if you are skipping storage for all authentication paths, you
  # may want to disable generating routes to Devise's sessions controller by
  # passing skip: :sessions to `devise_for` in your config/routes.rb
  config.skip_session_storage = [:http_auth]

  # By default, Devise cleans up the CSRF token on authentication to
  # avoid CSRF token fixation attacks. This means that, when using AJAX
  # requests for sign in and sign up, you need to get a new CSRF token
  # from the server. You can disable this option at your own risk.
  # config.clean_up_csrf_token_on_authentication = true

  # ==> Configuration for :database_authenticatable
  # For bcrypt, this is the cost for hashing the password and defaults to 10. If
  # using other encryptors, it sets how many times you want the password re-encrypted.
  #
  # Limiting the stretches to just one in testing will increase the performance of
  # your test suite dramatically. However, it is STRONGLY RECOMMENDED to not use
  # a value less than 10 in other environments. Note that, for bcrypt (the default
  # encryptor), the cost increases exponentially with the number of stretches (e.g.
  # a value of 20 is already extremely slow: approx. 60 seconds for 1 calculation).
  config.stretches = Rails.env.test? ? 1 : 10

  # Setup a pepper to generate the encrypted password.
  # config.pepper = '70defcd162929be0944c596d453635a22fae1fef85791d4157fab3c11039e5369c14aa73c571052424f6a25f4e67883a5e108cd06d7c8ba938f6f20e6ad4539f'

  # Send a notification email when the user's password is changed
  # config.send_password_change_notification = false

  # ==> Configuration for :invitable
  # The period the generated invitation token is valid, after
  # this period, the invited resource won't be able to accept the invitation.
  # When invite_for is 0 (the default), the invitation won't expire.
  # config.invite_for = 2.weeks

  # Number of invitations users can send.
  # - If invitation_limit is nil, there is no limit for invitations, users can
  # send unlimited invitations, invitation_limit column is not used.
  # - If invitation_limit is 0, users can't send invitations by default.
  # - If invitation_limit n > 0, users can send n invitations.
  # You can change invitation_limit column for some users so they can send more
  # or less invitations, even with global invitation_limit = 0
  # Default: nil
  # config.invitation_limit = 5

  # The key to be used to check existing users when sending an invitation
  # and the regexp used to test it when validate_on_invite is not set.
  # config.invite_key = {:email => /\A[^@]+@[^@]+\z/}
  # config.invite_key = {:email => /\A[^@]+@[^@]+\z/, :username => nil}

  # Flag that force a record to be valid before being actually invited
  # Default: false
  # config.validate_on_invite = true

  # Resend invitation if user with invited status is invited again
  # Default: true
  # config.resend_invitation = false

  # The class name of the inviting model. If this is nil,
  # the #invited_by association is declared to be polymorphic.
  # Default: nil
  # config.invited_by_class_name = 'User'

  # The foreign key to the inviting model (if invited_by_class_name is set)
  # Default: :invited_by_id
  # config.invited_by_foreign_key = :invited_by_id

  # The column name used for counter_cache column. If this is nil,
  # the #invited_by association is declared without counter_cache.
  # Default: nil
  # config.invited_by_counter_cache = :invitations_count

  # Auto-login after the user accepts the invite. If this is false,
  # the user will need to manually log in after accepting the invite.
  # Default: true
  # config.allow_insecure_sign_in_after_accept = false

  # ==> Configuration for :confirmable
  # A period that the user is allowed to access the website even without
  # confirming their account. For instance, if set to 2.days, the user will be
  # able to access the website for two days without confirming their account,
  # access will be blocked just in the third day. Default is 0.days, meaning
  # the user cannot access the website without confirming their account.
  # config.allow_unconfirmed_access_for = 2.days

  # A period that the user is allowed to confirm their account before their
  # token becomes invalid. For example, if set to 3.days, the user can confirm
  # their account within 3 days after the mail was sent, but on the fourth day
  # their account can't be confirmed with the token any more.
  # Default is nil, meaning there is no restriction on how long a user can take
  # before confirming their account.
  # config.confirm_within = 3.days

  # If true, requires any email changes to be confirmed (exactly the same way as
  # initial account confirmation) to be applied. Requires additional unconfirmed_email
  # db field (see migrations). Until confirmed, new email is stored in
  # unconfirmed_email column, and copied to email column on successful confirmation.
  config.reconfirmable = true

  # Defines which key will be used when confirming an account
  # config.confirmation_keys = [:email]

  # ==> Configuration for :rememberable
  # The time the user will be remembered without asking for credentials again.
  # config.remember_for = 2.weeks

  # Invalidates all the remember me tokens when the user signs out.
  config.expire_all_remember_me_on_sign_out = true

  # If true, extends the user's remember period when remembered via cookie.
  # config.extend_remember_period = false

  # Options to be passed to the created cookie. For instance, you can set
  # secure: true in order to force SSL only cookies.
  # config.rememberable_options = {}

  # ==> Configuration for :validatable
  # Range for password length.
  config.password_length = 8..72

  # Email regex used to validate email formats. It simply asserts that
  # one (and only one) @ exists in the given string. This is mainly
  # to give user feedback and not to assert the e-mail validity.
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  # config.timeout_in = 30.minutes

  # ==> Configuration for :lockable
  # Defines which strategy will be used to lock an account.
  # :failed_attempts = Locks an account after a number of failed attempts to sign in.
  # :none            = No lock strategy. You should handle locking by yourself.
  # config.lock_strategy = :failed_attempts

  # Defines which key will be used when locking and unlocking an account
  # config.unlock_keys = [:email]

  # Defines which strategy will be used to unlock an account.
  # :email = Sends an unlock link to the user email
  # :time  = Re-enables login after a certain amount of time (see :unlock_in below)
  # :both  = Enables both strategies
  # :none  = No unlock strategy. You should handle unlocking by yourself.
  # config.unlock_strategy = :both

  # Number of authentication tries before locking an account if lock_strategy
  # is failed attempts.
  # config.maximum_attempts = 20

  # Time interval to unlock the account if :time is enabled as unlock_strategy.
  # config.unlock_in = 1.hour

  # Warn on the last attempt before the account is locked.
  # config.last_attempt_warning = true

  # ==> Configuration for :recoverable
  #
  # Defines which key will be used when recovering the password for an account
  # config.reset_password_keys = [:email]

  # Time interval you can reset your password with a reset password key.
  # Don't put a too small interval or your users won't have the time to
  # change their passwords.
  config.reset_password_within = 6.hours

  # When set to false, does not sign a user in automatically after their password is
  # reset. Defaults to true, so a user is signed in automatically after a reset.
  # config.sign_in_after_reset_password = true

  # ==> Configuration for :encryptable
  # Allow you to use another encryption algorithm besides bcrypt (default). You can use
  # :sha1, :sha512 or encryptors from others authentication tools as :clearance_sha1,
  # :authlogic_sha512 (then you should set stretches above to 20 for default behavior)
  # and :restful_authentication_sha1 (then you should set stretches to 10, and copy
  # REST_AUTH_SITE_KEY to pepper).
  #
  # Require the `devise-encryptable` gem when using anything other than bcrypt
  # config.encryptor = :sha512

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check for
  # "users/sessions/new". It's turned off by default because it's slower if you
  # are using only default views.
  # config.scoped_views = false

  # Configure the default scope given to Warden. By default it's the first
  # devise role declared in your routes (usually :user).
  # config.default_scope = :user

  # Set this configuration to false if you want /users/sign_out to sign out
  # only the current scope. By default, Devise signs out all scopes.
  # config.sign_out_all_scopes = true

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html, should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  #
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists.
  #
  # The "*/*" below is required to match Internet Explorer requests.
  # config.navigational_formats = ['*/*', :html]

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :get

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  # config.omniauth :github, 'APP_ID', 'APP_SECRET', scope: 'user,public_repo'
  # require 'omniauth/strategies/dynamic'
  # config.omniauth :dynamic, :strategy_class => OmniAuth::Strategies::Dynamic,
  #                 provider: lambda {
  # #                 lambda { |env|
  # #   #request = Rack::Request.new(env)
  #                                                                                           #
  #   provider = AuthProvider.first #nd_by(name: request.params['provider'])

  #   if provider
  #     provider
  #   else
  #     nil
  #   end
  # }
  idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
  idp_metadata = idp_metadata_parser.parse_remote_to_hash("https://passport.pitt.edu/idp/shibboleth")
  config.omniauth :saml, {
    :idp_entity_id=>"https://passport.pitt.edu/idp/shibboleth",
    :name_identifier_format=>"urn:oasis:names:tc:SAML:2.0:nameid-format:transient",
    :idp_sso_service_url=>"https://passport.pitt.edu/idp/profile/SAML2/Redirect/SSO",
    :idp_sso_service_binding=>"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect",
    :idp_slo_service_url=>nil,
    :idp_cert=>'MIIDLzCCAhegAwIBAgIUZiByS7B062+ol+pZKrqkwBxrqLUwDQYJKoZIhvcNAQEL BQAwHDEaMBgGA1UEAwwRcGFzc3BvcnQucGl0dC5lZHUwHhcNMTUxMTEzMTczMDQ3 WhcNMzUxMTEzMTczMDQ3WjAcMRowGAYDVQQDDBFwYXNzcG9ydC5waXR0LmVkdTCC ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAIXgP4IOEjINaJ9dePEzc5Wp J8+Ytw0Ojc/JlImfMlUf9yiwiQZQhYIv7C7KmSIgBBvzj/4e6x+tGioE3vIPq9Yz 47zLOUjzsPgSXnmqSujVCF1zce5aXsjwNcZ5JFN037pgoNLpwtuzfLg9sPbTdQV4 dRGE07eIXiil6+ER1diFrmGQYSrlfY8DX4sZzl7er6eNEkN5bb3sYK4W13g54Vwf BT9/nZe8dsVq7HSZeGdqtyU9Vm49BxpRJLi/X1xsoTCsa8jSRGhpfktR/UygnMWc oKfayjUC/3fjyBBEvb2EbIiAByYZeApM8zCynHpoHbNTCECIfmkQ6YYohEVave8C AwEAAaNpMGcwHQYDVR0OBBYEFAguZrxqsqNCg5KQhdAnsGrSFZEgMEYGA1UdEQQ/ MD2CEXBhc3Nwb3J0LnBpdHQuZWR1hihodHRwczovL3Bhc3Nwb3J0LnBpdHQuZWR1 L2lkcC9zaGliYm9sZXRoMA0GCSqGSIb3DQEBCwUAA4IBAQBdX30sZVe9QfYYJydn x+nWdKeGT0FxqPHaLaa/NHREOetOG1DHYCi617zy0bXq9Vnm+bZpqIheBHwzGzpk U5MJrPjwnmy1YyjoFNKy9N5KTQ+nCv7fKfLv55LSNE685T144B2KcRcFg3cDd2jt keVXfOYIBWnyEPnFeTlVA5Y16kbly78ixjTRGXaSLtrwCOJ25kM2+RAyZwp6/lHC S6tSx6TluEVAaA9y/ByyF41xdJk6iqgtqR6NmUIZLZlJ5dAOoyddHFgzWnKCqvtF RtrlnjGNwrHyXGWJbgY7wixreqLbBKAQ+nbaesqlCii8lR/5LawpnSAZmGD2diwl 133k',
    :issuer=>"https://dev.hyku.test",
  }
 
  # <samlp:AuthnRequest 
  #   AssertionConsumerServiceURL='https://dev.hyku.test/users/auth/saml/callback?locale=en' 
  #   Destination='https://passport.pitt.edu/idp/profile/Shibboleth/SSO' 
  #   ID='_71f41f3e-b5b6-4777-8bbe-53be0efc5624' 
  #   IssueInstant='2023-06-27T23:10:58Z' 
  #   Version='2.0' 
  #   xmlns:saml='urn:oasis:names:tc:SAML:2.0:assertion' 
  #   xmlns:samlp='urn:oasis:names:tc:SAML:2.0:protocol'>
  #     <samlp:NameIDPolicy AllowCreate='true' 
  #         Format='urn:mace:shibboleth:1.0:nameIdentifier'/>
  # </samlp:AuthnRequest>


  # ==> Warden configuration
  # If you want to use other strategies, that are not supported by Devise, or
  # change the failure app, you can configure them inside the config.warden block.
  #
  # config.warden do |manager|
  #   manager.intercept_401 = false
  #   manager.default_strategies(scope: :user).unshift :some_external_strategy
  # end

  # ==> Mountable engine configurations
  # When using Devise inside an engine, let's call it `MyEngine`, and this engine
  # is mountable, there are some extra configurations to be taken into account.
  # The following options are available, assuming the engine is mounted as:
  #
  #     mount MyEngine, at: '/my_engine'
  #
  # The router that invoked `devise_for`, in the example above, would be:
  # config.router_name = :my_engine
  #
  # When using OmniAuth, Devise cannot automatically set OmniAuth path,
  # so you need to do it manually. For the users scope, it would be:
  # config.omniauth_path_prefix = '/my_engine/users/auth'
end

# urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect
# https://passport.pitt.edu/idp/profile/SAML2/Redirect/SSO
# urn:oasis:names:tc:SAML:2.0:nameid-format:transient
# MIIDLzCCAhegAwIBAgIUZiByS7B062+ol+pZKrqkwBxrqLUwDQYJKoZIhvcNAQEL BQAwHDEaMBgGA1UEAwwRcGFzc3BvcnQucGl0dC5lZHUwHhcNMTUxMTEzMTczMDQ3 WhcNMzUxMTEzMTczMDQ3WjAcMRowGAYDVQQDDBFwYXNzcG9ydC5waXR0LmVkdTCC ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAIXgP4IOEjINaJ9dePEzc5Wp J8+Ytw0Ojc/JlImfMlUf9yiwiQZQhYIv7C7KmSIgBBvzj/4e6x+tGioE3vIPq9Yz 47zLOUjzsPgSXnmqSujVCF1zce5aXsjwNcZ5JFN037pgoNLpwtuzfLg9sPbTdQV4 dRGE07eIXiil6+ER1diFrmGQYSrlfY8DX4sZzl7er6eNEkN5bb3sYK4W13g54Vwf BT9/nZe8dsVq7HSZeGdqtyU9Vm49BxpRJLi/X1xsoTCsa8jSRGhpfktR/UygnMWc oKfayjUC/3fjyBBEvb2EbIiAByYZeApM8zCynHpoHbNTCECIfmkQ6YYohEVave8C AwEAAaNpMGcwHQYDVR0OBBYEFAguZrxqsqNCg5KQhdAnsGrSFZEgMEYGA1UdEQQ/ MD2CEXBhc3Nwb3J0LnBpdHQuZWR1hihodHRwczovL3Bhc3Nwb3J0LnBpdHQuZWR1 L2lkcC9zaGliYm9sZXRoMA0GCSqGSIb3DQEBCwUAA4IBAQBdX30sZVe9QfYYJydn x+nWdKeGT0FxqPHaLaa/NHREOetOG1DHYCi617zy0bXq9Vnm+bZpqIheBHwzGzpk U5MJrPjwnmy1YyjoFNKy9N5KTQ+nCv7fKfLv55LSNE685T144B2KcRcFg3cDd2jt keVXfOYIBWnyEPnFeTlVA5Y16kbly78ixjTRGXaSLtrwCOJ25kM2+RAyZwp6/lHC S6tSx6TluEVAaA9y/ByyF41xdJk6iqgtqR6NmUIZLZlJ5dAOoyddHFgzWnKCqvtF RtrlnjGNwrHyXGWJbgY7wixreqLbBKAQ+nbaesqlCii8lR/5LawpnSAZmGD2diwl 133k

#  {:idp_entity_id=>"https://passport.pitt.edu/idp/shibboleth", 
#   :name_identifier_format=>"urn:mace:shibboleth:1.0:nameIdentifier", 
#   :idp_sso_service_url=>"https://passport.pitt.edu/idp/profile/Shibboleth/SSO", 
#   :idp_sso_service_binding=>"urn:mace:shibboleth:1.0:profiles:AuthnRequest", 
#   :idp_slo_service_url=>nil, :idp_slo_service_binding=>nil, :idp_slo_response_service_url=>nil, 
#   :idp_attribute_names=>[], :idp_cert=>nil, :idp_cert_fingerprint=>nil, 
#   :idp_cert_multi=>{:signing=>["\nMIIDLzCCAhegAwIBAgIUZiByS7B062+ol+pZKrqkwBxrqLUwDQYJKoZIhvcNAQEL\nBQAwHDEaMBgGA1UEAwwRcGFzc3BvcnQucGl0dC5lZHUwHhcNMTUxMTEzMTczMDQ3\nWhcNMzUxMTEzMTczMDQ3WjAcMRowGAYDVQQDDBFwYXNzcG9ydC5waXR0LmVkdTCC\nASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAIXgP4IOEjINaJ9dePEzc5Wp\nJ8+Ytw0Ojc/JlImfMlUf9yiwiQZQhYIv7C7KmSIgBBvzj/4e6x+tGioE3vIPq9Yz\n47zLOUjzsPgSXnmqSujVCF1zce5aXsjwNcZ5JFN037pgoNLpwtuzfLg9sPbTdQV4\ndRGE07eIXiil6+ER1diFrmGQYSrlfY8DX4sZzl7er6eNEkN5bb3sYK4W13g54Vwf\nBT9/nZe8dsVq7HSZeGdqtyU9Vm49BxpRJLi/X1xsoTCsa8jSRGhpfktR/UygnMWc\noKfayjUC/3fjyBBEvb2EbIiAByYZeApM8zCynHpoHbNTCECIfmkQ6YYohEVave8C\nAwEAAaNpMGcwHQYDVR0OBBYEFAguZrxqsqNCg5KQhdAnsGrSFZEgMEYGA1UdEQQ/\nMD2CEXBhc3Nwb3J0LnBpdHQuZWR1hihodHRwczovL3Bhc3Nwb3J0LnBpdHQuZWR1\nL2lkcC9zaGliYm9sZXRoMA0GCSqGSIb3DQEBCwUAA4IBAQBdX30sZVe9QfYYJydn\nx+nWdKeGT0FxqPHaLaa/NHREOetOG1DHYCi617zy0bXq9Vnm+bZpqIheBHwzGzpk\nU5MJrPjwnmy1YyjoFNKy9N5KTQ+nCv7fKfLv55LSNE685T144B2KcRcFg3cDd2jt\nkeVXfOYIBWnyEPnFeTlVA5Y16kbly78ixjTRGXaSLtrwCOJ25kM2+RAyZwp6/lHC\nS6tSx6TluEVAaA9y/ByyF41xdJk6iqgtqR6NmUIZLZlJ5dAOoyddHFgzWnKCqvtF\nRtrlnjGNwrHyXGWJbgY7wixreqLbBKAQ+nbaesqlCii8lR/5LawpnSAZmGD2diwl\n133k\n                        ", "\nMIIDLzCCAhegAwIBAgIUZiByS7B062+ol+pZKrqkwBxrqLUwDQYJKoZIhvcNAQEL\nBQAwHDEaMBgGA1UEAwwRcGFzc3BvcnQucGl0dC5lZHUwHhcNMTUxMTEzMTczMDQ3\nWhcNMzUxMTEzMTczMDQ3WjAcMRowGAYDVQQDDBFwYXNzcG9ydC5waXR0LmVkdTCC\nASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAIXgP4IOEjINaJ9dePEzc5Wp\nJ8+Ytw0Ojc/JlImfMlUf9yiwiQZQhYIv7C7KmSIgBBvzj/4e6x+tGioE3vIPq9Yz\n47zLOUjzsPgSXnmqSujVCF1zce5aXsjwNcZ5JFN037pgoNLpwtuzfLg9sPbTdQV4\ndRGE07eIXiil6+ER1diFrmGQYSrlfY8DX4sZzl7er6eNEkN5bb3sYK4W13g54Vwf\nBT9/nZe8dsVq7HSZeGdqtyU9Vm49BxpRJLi/X1xsoTCsa8jSRGhpfktR/UygnMWc\noKfayjUC/3fjyBBEvb2EbIiAByYZeApM8zCynHpoHbNTCECIfmkQ6YYohEVave8C\nAwEAAaNpMGcwHQYDVR0OBBYEFAguZrxqsqNCg5KQhdAnsGrSFZEgMEYGA1UdEQQ/\nMD2CEXBhc3Nwb3J0LnBpdHQuZWR1hihodHRwczovL3Bhc3Nwb3J0LnBpdHQuZWR1\nL2lkcC9zaGliYm9sZXRoMA0GCSqGSIb3DQEBCwUAA4IBAQBdX30sZVe9QfYYJydn\nx+nWdKeGT0FxqPHaLaa/NHREOetOG1DHYCi617zy0bXq9Vnm+bZpqIheBHwzGzpk\nU5MJrPjwnmy1YyjoFNKy9N5KTQ+nCv7fKfLv55LSNE685T144B2KcRcFg3cDd2jt\nkeVXfOYIBWnyEPnFeTlVA5Y16kbly78ixjTRGXaSLtrwCOJ25kM2+RAyZwp6/lHC\nS6tSx6TluEVAaA9y/ByyF41xdJk6iqgtqR6NmUIZLZlJ5dAOoyddHFgzWnKCqvtF\nRtrlnjGNwrHyXGWJbgY7wixreqLbBKAQ+nbaesqlCii8lR/5LawpnSAZmGD2diwl\n133k\n                        "], :encryption=>["\nMIIDMDCCAhigAwIBAgIVANJ07z1fNkIV0lD9Ve89KN3gzBKSMA0GCSqGSIb3DQEB\nCwUAMBwxGjAYBgNVBAMMEXBhc3Nwb3J0LnBpdHQuZWR1MB4XDTE1MTExMzE3MzA0\nOFoXDTM1MTExMzE3MzA0OFowHDEaMBgGA1UEAwwRcGFzc3BvcnQucGl0dC5lZHUw\nggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCAadDai5NaRQW9XOuD0KHw\nGCeYzsUyKvGwi4AhcQBB2D5ZwVEZhg08NCvlD8s2kmlQIL58BDhe8/UKF+cFV9jR\nksiUDuIYY1L8ypm/9A0jKjq4J5dbY+zlkfpze8C34/qTIA5owBNmvlL4b6llOBV2\nsrDCbv2mho3j7fJICv+fm/SovPFQJBO8zVeNomXjm97aY9TRfrhzlZ0wVwAy700u\nuXRAar7qP+gC23gwAR4fL5WvI/kNABgcGPnBSnUOra1hxNtcK1MLgyqJbBkYosSR\njwlvHTyFICaR+KGqiuLJLPVn6SMlzs2ND20CHxOaz2oz3746ZTJDoHoQc/dvuOA3\nAgMBAAGjaTBnMB0GA1UdDgQWBBTyBzAX8brmshdB0o8aSTWVOg6MFTBGBgNVHREE\nPzA9ghFwYXNzcG9ydC5waXR0LmVkdYYoaHR0cHM6Ly9wYXNzcG9ydC5waXR0LmVk\ndS9pZHAvc2hpYmJvbGV0aDANBgkqhkiG9w0BAQsFAAOCAQEAG2Ou9h7e4oED7Vou\nCeMh58qC9pt4H3gleMexTaZ2VovE7i/orVkbB36Ik6lplEjlo8o54PXurGIUOpm9\nbTGNuGODTMjjq6ojUNSawpz7W7DRqxJJvLTh2gGJSNCX3AOhfmDJvxCpHaOlEZ3R\nAlpGnV7EpG3uTaE4YCvep16gCpAyjJhmqV5ouMswH6SxXzUG4UqJAm+obblgoqcC\nXajmdjCN8hayTFsVy1H3a82M+zhcdpFo+QraqVan3Z29Lf9LIbGqngxWxGE4mchi\njdaqsVSwq38Xr96uO/Apms/9CPL/CayrvlbPpvcv0u9z5uEmmssPdW4DhaILLsRo\nzdvadQ==\n                        "]}, 
#   :valid_until=>nil, 
#   :cache_duration=>nil
# }