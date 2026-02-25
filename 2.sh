cd /opt/redmine

# Очистите кэш Rails
RAILS_ENV=production bundle exec rails tmp:clear
RAILS_ENV=production bundle exec rails tmp:cache:clear

# Очистите assets
RAILS_ENV=production bundle exec rails assets:clobber
RAILS_ENV=production bundle exec rails assets:precompile

# Перезапустите
pkill -f "rails server" 2>/dev/null
sleep 2
bundle exec rails server -e production -b 192.168.1.29 -p 3000
