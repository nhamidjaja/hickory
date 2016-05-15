source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.2'

# Postgres client
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Deployment
gem 'capistrano', '~> 3.5.0', group: :development, require: false
gem 'capistrano-rails', '~> 1.1', group: :development, require: false
gem 'capistrano-figaro-yml', '~> 1.0.2', group: :development, require: false
gem 'capistrano-bundler', group: :development, require: false
gem 'capistrano3-puma', github: 'seuros/capistrano-puma', branch: 'master', group: :development, require: false
gem 'capistrano-sidekiq', group: :development, require: false

# App server
gem 'puma'

# UI
gem 'bootstrap-sass'
gem 'font-awesome-rails'
gem 'nprogress-rails'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Cassandra ORM
gem 'cequel'

# Database replication
gem 'ar-octopus'

# ID generator
# gem 'activeuuid'

# User authentication
gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'

# View templating engine
gem 'slim'

# Background worker
gem 'sidekiq'
# if you require 'sinatra' you get the DSL extended to Object
gem 'sinatra', require: false

# Server monitoring
gem 'newrelic_rpm'

# Parallel HTTP requests
gem 'typhoeus'

# Facebook Graph API wrapper
gem 'koala'

# RSS parser
gem 'feedjira'

# Environment-specific configurations
gem 'figaro'

gem 'rails_admin'

# cron syntactic sugar
gem 'whenever', require: false

# Test automation
gem 'rspec-rails', group: [:development, :test]
gem 'guard-rspec', group: :development, require: false
gem 'guard-sidekiq', group: :development, require: false
gem 'factory_girl_rails', group: [:development, :test]
gem 'faker', group: [:development, :test]

# Ruby style checker
gem 'rubocop', group: :development, require: false

# Test coverage analyzer
gem 'simplecov', group: :test, require: false

# PostgreSQL search
gem 'pg_search'

gem 'redis-namespace'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end
