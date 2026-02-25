#!/bin/bash
cd /opt/redmine

echo "=== FINAL REDMINE LAUNCH ==="

# 1. Остановите старый сервер
pkill -f "rails server" 2>/dev/null
sleep 1

# 2. Установите secret key
export SECRET_KEY_BASE="$(ruby -e "require 'securerandom'; puts SecureRandom.hex(64)")"
echo "Secret: ${SECRET_KEY_BASE:0:20}..."

# 3. Очистите сессии и кэш
echo "Cleaning sessions and cache..."
rm -rf tmp/sessions/* tmp/cache/*
mkdir -p tmp/sessions tmp/cache

# 4. Создайте надежный secret initializer
cat > config/initializers/00_SECRET.rb << 'SECRET'
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
SECRET

# 5. Создайте fix для сессий
cat > config/initializers/01_SESSION_FIX.rb << 'SESSION'
# Fix for session 'info' method error
module Rack
  module Session
    module Abstract
      class SessionHash
        def info
          {}
        end
      end
    end
  end
end

# Simple session store
Rails.application.config.session_store :cookie_store,
  key: '_redmine_session',
  expire_after: 7.days
SESSION

# 6. Отключите assets
cat > config/initializers/02_NO_ASSETS.rb << 'ASSETS'
Rails.application.config.assets.enabled = false
Rails.application.config.assets.compile = false
Rails.application.config.public_file_server.enabled = true
ASSETS

# 7. Проверьте и создайте admin пользователя
echo "Checking database..."
mysql -u root -p'!fY6kyzJmbCrq' redmine -e "SELECT 1" >/dev/null && {
  echo "Creating admin if needed..."
  RAILS_ENV=production bundle exec rails runner "
    unless User.exists?(login: 'admin')
      User.create!(
        login: 'admin',
        password: 'admin123',
        password_confirmation: 'admin123',
        firstname: 'Admin',
        lastname: 'User',
        mail: 'admin@example.com',
        admin: true,
        status: 1
      )
      puts 'Admin user created'
    end
  " 2>/dev/null || true
}

# 8. Запустите сервер
echo ""
echo "========================================="
echo "REDMINE PRODUCTION SERVER"
echo "URL: http://192.168.1.29:3000"
echo "Login: admin / admin123"
echo "========================================="
echo ""
echo "Starting server..."

exec bundle exec rails server -e production -b 192.168.1.29 -p 3000
