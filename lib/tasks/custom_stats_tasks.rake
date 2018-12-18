# frozen_string_literal: true
namespace :custom_stats do
  desc "reset work/file index"
  task reset_index: :environment do
    WorkAndFileIndex.reset
  end

  desc "update work/file index"
  task update_index: :environment do
    WorkAndFileIndex.update_works_and_files
  end

  desc "start user stats update"
  task collect: :environment do
    limit = ENV["LIMIT"].to_i
    delay = ENV["DELAY"].to_i
    retries = ENV["RETRIES"].to_i

    WorkAndFileIndex.order(stats_last_gathered: :asc).limit(limit).each do |object|
      importer = Hyrax::CustomStatImporter.new(object, delay_secs: delay, retries: retries, verbose: true, logging: true)
      importer.import
    end

    Hyrax::UserStatAdder.reset_user_stats
  end
end
