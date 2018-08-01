# frozen_string_literal: true
namespace :manifest do
  desc "Run all manifest reports"
  task all: [:works, :files, :users, :collections] do
  end

  desc "Run work manifest reports"
  task works: :environment do
    WorksReport.create_report
  end

  desc "Run files manifest reports"
  task files: :environment do
    FilesReport.create_report
  end

  desc "Run users manifest reports"
  task users: :environment do
    UsersReport.create_report
  end

  desc "Run collections manifest reports"
  task collections: :environment do
    CollectionsReport.create_report
  end
end
