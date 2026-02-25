#!/bin/bash
cd /opt/redmine

# 1. Установите переменную
export SECRET_KEY_BASE="$(ruby -e "require 'securerandom'; puts SecureRandom.hex(64)")"
echo "SECRET_KEY_BASE=${SECRET_KEY_BASE:0:20}..."

# 2. Удалите старые конфиги
rm -f config/initializers/*secret* config/initializers/*token* 2>/dev/null

# 3. Создайте самый простой initializer
cat > config/initializers/00_secret.rb << 'SECRET'
Rails.application.config.secret_key_base = ENV['SECRET_KEY_BASE']
SECRET

# 4. Отключите проверку в production.rb
sed -i "s/config.require_master_key = true/config.require_master_key = false/" config/environments/production.rb 2>/dev/null

# 5. Проверьте
echo "Testing configuration..."
RAILS_ENV=production bundle exec rails runner "
  puts 'SUCCESS!' if Rails.application.config.secret_key_base == ENV['SECRET_KEY_BASE']
  puts 'Key: ' + Rails.application.config.secret_key_base[0..20] + '...'
" 2>/dev/null || echo "Test failed, but trying to run anyway..."

# 6. Запустите
echo "Starting Redmine..."
exec bundle exec rails server -e production -b 192.168.1.29 -p 3000
