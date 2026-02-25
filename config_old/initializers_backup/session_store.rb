# Be sure to restart your server when you modify this file.
Rails.application.config.session_store :cookie_store,
  key: '_redmine_session',
  expire_after: 7.days,
  secure: Rails.env.production?,
  httponly: true,
  same_site: :lax

# Ensure session middleware is properly configured
Rails.application.config.middleware.insert_before(
  ActionDispatch::Cookies,
  Rack::Session::Cookie,
  key: '_redmine_session',
  expire_after: 7.days,
  secret: Rails.application.config.secret_key_base
)
