# Be sure to restart your server when you modify this file.

if Rails.env.test?
  Rails.application.config.session_store :cookie_store, key: '_hyku_session'
else
  Rails.application.config.session_store :cookie_store, key: '_hyku_session', domain: [".#{ENV['HYKU_ROOT_HOST']}", 'mushare.marian.edu']
end
