cd /opt/redmine

# 1. Исправьте environment.rb
sed -i '16s/.*//' config/environment.rb

# 2. Создайте пустой importmap конфиг
mkdir -p config/importmap
echo '{}' > config/importmap.rb

# 3. Установите listen
bundle config unset without
bundle install

# 4. Создайте БД
RAILS_ENV=development bundle exec rails db:create
