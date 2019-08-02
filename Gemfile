# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'browse-everything', github: 'uclibs/browse-everything', branch: 'master'
gem 'hydra-remote_identifier', github: 'uclibs/hydra-remote_identifier', branch: 'scholar-datacite'
gem 'kaltura', '0.1.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.6.2'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '1.3.13'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'active-fedora', '11.5.4'
gem 'active_attr'
gem 'bootstrap-sass', '~> 3.4.1'
gem 'bundler', '~> 1.17'
gem 'change_manager', git: "https://github.com/uclibs/change_manager.git", ref: 'd8e1b552740df00922a0a40796999c4e2a0cb8b6'
gem 'devise', '~> 4.6.0'
gem 'devise-guests', '~> 0.6'
gem 'devise-multi_auth', git: 'https://github.com/uclibs/devise-multi_auth', branch: 'rails-5.1.6.2'
gem 'dotenv-rails'
gem 'equivalent-xml'
gem 'hydra-role-management'
gem 'hyrax', git: 'https://github.com/samvera/hyrax.git', tag: 'v2.3.3'
gem 'mysql2', '~> 0.4.10'
gem 'omniauth-openid'
gem 'omniauth-shibboleth'
gem 'orcid', git: 'https://github.com/uclibs/orcid', branch: 'rails-5.1.6.2'
gem 'riiif', '~> 2.0'
gem 'rsolr', '>= 1.0'
gem 'sassc-rails', '>= 2.1.0'
gem 'sidekiq'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'bixby', '>= 1.0.0'
  gem 'byebug', platform: :mri
  gem 'fcrepo_wrapper'
  gem 'rails-controller-testing'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'show_me_the_cookies'
  gem 'solr_wrapper', '>= 0.3'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.0.5'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # Disabling Spring because in interferes with loading environment variables
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
  gem "capistrano", "~> 3.10", require: false
  gem 'capistrano-bundler', '~> 1.6', require: false
  gem "capistrano-rails", "~> 1.3", require: false
  gem "capistrano-rvm", require: false
end

group :test do
  gem 'capybara', '~> 2.4', '< 2.18.0'
  gem 'capybara-maleficent', '~> 0.2'
  gem 'coveralls', '~> 0.8.22', require: false
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-retry'
  gem 'selenium-webdriver', '3.12.0'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'webdrivers', '~> 3.0'
end

group :production do
  gem 'clamav'
end
