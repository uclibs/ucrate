# frozen_string_literal: true

require 'rspec/core'
require 'rspec/core/rake_task'
require 'solr_wrapper'
require 'fcrepo_wrapper'
require 'active_fedora/rake_support'

desc 'Spin up test servers and run specs'
task :spec_with_app_load do
  reset_statefile! if ENV['TRAVIS'] == 'true'
  with_test_server do
    Rake::Task['spec'].invoke
  end
end

desc 'Generate the engine_cart and spin up test servers and run specs'
task :ci do
  puts 'running continuous integration'
  Rake::Task['spec_with_app_load'].invoke
end

def reset_statefile!
  FileUtils.rm_f('/tmp/minter-state')
end
