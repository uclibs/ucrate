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
    if ENV['TRAVIS']
      case ENV['SPEC_GROUP'].to_s
      when '0'
        Rake::Task['feature_spec'].invoke
      else
        Rake::Task['spec_without_feature'].invoke
      end
    else
      Rake::Task['all_spec'].invoke
    end
  end
end

desc "Run all spec"
RSpec::Core::RakeTask.new(:all_spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

desc "Run feature spec"
RSpec::Core::RakeTask.new(:feature_spec) do |t|
  t.pattern = 'spec/features/**/*_spec.rb'
end

desc "Run spec without feture"
RSpec::Core::RakeTask.new(:spec_without_feature) do |t|
  pattern = FileList['spec/*/'].exclude(/\/(features)\//).map { |f| f << '**/*_spec.rb' }
  t.pattern = pattern
end

desc 'Generate the engine_cart and spin up test servers and run specs'
task :ci do
  puts 'running continuous integration'
  Rake::Task['spec_with_app_load'].invoke
end

def reset_statefile!
  FileUtils.rm_f('/tmp/minter-state')
end
