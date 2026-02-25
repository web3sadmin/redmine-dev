# Минимальный secret
Rails.application.config.secret_key_base = ENV['SECRET_KEY_BASE'] || 'test_secret_key_base_placeholder_1234567890abcdef'
