# frozen_string_literal: true
# config valid for current version and patch releases of Capistrano
lock "~> 3.11"
set :application, "Scholar"
set :repo_url, "https://github.com/uclibs/ucrate.git"
set :keep_releases, 2

task :shared_db do
  on roles(:all) do
    execute "mkdir -p #{fetch(:deploy_to)}/shared/db/ && touch #{fetch(:deploy_to)}/shared/db/development.sqlite3"
    execute "cp #{fetch(:deploy_to)}/static/.env.development.local #{fetch(:release_path)}/ || true"
  end
end

task :start_local do
  on roles(:all) do
    execute "export PATH=$PATH:/usr/local/bin && cd #{fetch(:deploy_to)}/current/script && source start_local.sh migrate"
  end
end

task :start_curly do
  on roles(:all) do
    execute "export PATH=$PATH:/usr/sbin/ && cd #{fetch(:deploy_to)}/current && chmod u+x script/* && source script/start_curly.sh"
  end
end

task :init_dev do
  on roles(:all) do
    execute "echo 'The deploy to Scholar@UC DEV has started' | mail -s 'Scholar@UC deploy started (scholar-dev)' scholar@uc.edu"
    execute "gem install --user-install bundler"
    execute "cp #{fetch(:deploy_to)}/static/scholar-dev.variables #{fetch(:release_path)}/.env.development.local 2> /dev/null"
  end
end

task :start_dev do
  on roles(:all) do
    execute "cd #{fetch(:deploy_to)}/current/script && chmod a+x * && source start_dev.sh"
  end
end

task :init_qa do
  on roles(:all) do
    execute 'echo "The deploy to `hostname` has started" | mail -s "Scholar@UC deploy started (`hostname`)" scholar@uc.edu'
    execute "gem install --user-install bundler"
    execute "cp #{fetch(:deploy_to)}/static/scholar-qa.variables #{fetch(:release_path)}/.env.production.local 2> /dev/null"
  end
end

task :start_qa do
  on roles(:all) do
    execute "cd #{fetch(:deploy_to)}/current/script && chmod a+x * && source start_qa.sh"
  end
end

task :init_prod do
  on roles(:all) do
    execute 'echo "The deploy to `hostname` has started" | mail -s "Scholar@UC deploy started (`hostname`)" scholar@uc.edu'
    execute "gem install --user-install bundler"
    execute "cp #{fetch(:deploy_to)}/static/scholar-production.variables #{fetch(:release_path)}/.env.production.local 2> /dev/null"
  end
end

task :start_prod do
  on roles(:all) do
    execute "cd #{fetch(:deploy_to)}/current/script && chmod a+x * && source start_prod.sh"
  end
end

namespace :deploy do
  task :confirmation do
    stage = fetch(:stage).upcase
    branch = fetch(:branch)
    puts <<-WARN
     ========================================================================
       *** Deploying branch `#{branch}` to #{stage} server ***
       WARNING: You're about to perform actions on #{stage} server(s)
       Please confirm that all your intentions are kind and friendly
     ========================================================================
     WARN
    ask :value, "Sure you want to continue deploying `#{branch}` on #{stage}? (Y)"
    unless fetch(:value).match?(/\A(?i:yes|y)\z/)
      puts "\nNo confirmation - deploy cancelled!"
      exit
    end
  end
end

Capistrano::DSL.stages.each do |stage|
  after stage, 'deploy:confirmation'
end
