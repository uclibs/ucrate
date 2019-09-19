# frozen_string_literal: true

set :rails_env, :development
set :bundle_without, %w[production test].join(' ')
set :branch, 'develop'
set :default_env, path: "$PATH:/srv/apps/.gem/ruby/2.5.0/bin:/opt/fits/fits"
set :bundle_path, -> { shared_path.join('vendor/bundle') }
# No db/development.sqlite3 file
# Note: Fedora and Solr are external
append :linked_dirs, "tmp", "log", "public"
ask(:username, nil)
ask(:password, nil, echo: false)
server "localhost", user: fetch(:username), password: fetch(:password), port: 2222, roles: [:web, :app, :db]
set :deploy_to, '/srv/apps/scholar_capistrano'
after "deploy:updating", "init_dev"
before "deploy:cleanup", "start_dev"
