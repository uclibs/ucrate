# frozen_string_literal: true
set :rails_env, :development
set :bundle_without, %w[production test].join(' ')
set :branch, 'chore/#761-deployment-alternative'
set :default_env, path: "$PATH:/usr/local/bin"
append :linked_files, "db/development.sqlite3"
append :linked_dirs, "tmp", "log", "public/system"
ask(:username, nil)
ask(:password, nil, echo: false)
server "localhost", user: fetch(:username), password: fetch(:password), port: 22, roles: [:web, :app, :db]
set :deploy_to, '~/scholar_capistrano'
after "deploy:updating", "shared_db"
before "deploy:cleanup", "start_local"
