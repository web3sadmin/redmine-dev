# ABSOLUTE SECRET SETTER
SECRET_FORCE = ENV['SECRET_KEY_BASE'].to_s
if SECRET_FORCE.length < 64
  require 'securerandom'
  SECRET_FORCE = SecureRandom.hex(64)
end

Rails.application.config.secret_key_base = SECRET_FORCE

# Disable validation
class << Rails.application.config
  def validate_secret_key_base
    true
  end
end
