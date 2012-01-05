source 'http://rubygems.org'

gem 'rails', '3.1.0'

# Database NO-SQL
gem 'mongoid'
gem 'bson_ext', '1.5.1'
gem 'mongo_sessions', :require => "mongo_sessions/rails_mongo_store"
gem 'tire'

# Push notifications
gem 'faye'

# Production dependencies
gem 'therubyracer'
gem 'execjs'
gem 'scout'

# Markup
gem 'haml'
gem 'haml-rails'
gem 'redcarpet'
gem 'kaminari'
gem 'pjax_rails'

# Styling
gem 'bootstrap-sass', '1.4.0'

# Authentication & Authorization
gem 'omniauth'
gem 'cancan'

# Forms
gem 'client_side_validations'

# Images and Image manipulation
gem 'fog'
gem 'cloudfiles'
gem 'mini_magick'
gem 'carrierwave'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'

# Others
gem 'bcrypt-ruby', :require => 'bcrypt'

# Assets
gem 'sass'
gem 'sass-rails'
gem 'coffee-script'
gem 'uglifier'
gem 'jquery-rails'
gem 'sprockets'

# Cloudsdale Specific
gem 'urifetch'

group :development, :test do
  gem 'pry'
  gem 'rails3-generators'
  gem 'rspec-rails'
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-rspec'
  gem 'guard-livereload'
end

group :development do
  gem 'gist'
  gem 'foreman'
  gem 'rails-dev-tweaks', '~> 0.5.2'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
end

gem 'capistrano'
gem 'capistrano_colors', :require => nil
gem 'unicorn'