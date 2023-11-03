# frozen_string_literal: true

set :rails_env, :production
set :bundle_without, %w[test].join(' ')
set :branch, 'main'
set :default_env, path: "$PATH:/srv/apps/.gem/ruby/2.7.0/bin:/opt/fits/fits"
set :bundle_path, -> { shared_path.join('vendor/bundle') }
# No db/development.sqlite3 file
# Note: Fedora and Solr are external
# Removed log linked directory for symlinks in script
append :linked_dirs, "tmp", "public"
ask(:username, nil)
ask(:password, nil, echo: false)
ask(:value, 'Have you submitted and received an approved Change Management Request? (Y)')
unless fetch(:value).match?(/\A(?i:yes|y)\z/)
  puts "\nNo confirmation - deploy cancelled!"
  exit
end
# NOTE: Removing :db from one of the servers makes the migrations run only once between thems
server "localhost", user: fetch(:username), password: fetch(:password), port: 2222, roles: [:web, :app, :db]
server "localhost", user: fetch(:username), password: fetch(:password), port: 2223, roles: [:web, :app]
set :deploy_to, '/srv/apps/scholar_capistrano'
after "deploy:updating", "init_prod"
before "deploy:cleanup", "start_prod"
