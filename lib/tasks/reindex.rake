# frozen_string_literal: true
namespace :reindex do
  desc "Reindex specified work, e.g., rake myreindex:reindex_by_id['c821gj76b']"
  task :reindex_by_id, [:id] => :environment do |_, args|
    object = find_or_warn(args[:id]) || next

    if object.id.blank?
      $stderr.puts "No such work exists for id: #{object.id}"
      next
    else
      ActiveFedora::Base.find(object.id).update_index
      puts "Reindexed work id #{object.id}"
    end
  end

  desc "Reindex collections"
  task reindex_collections: :environment do
    count = 0
    Collection.all.each do |object|
      if object.id.blank?
        $stderr.puts "No such work exists for id: #{object.id}"
        next
      else
        ActiveFedora::Base.find(object.id).update_index
        count += 1
      end
    end
    puts "Reindexed works for #{count} objects"
  end

  desc "Reindex all objects"
  task reindex_works: :environment do
    count = 0
    [Image, Document, ExternalObject, MedSym, Review].each do |model_class|
      model_class.all.each do |object|
        if object.id.blank?
          $stderr.puts "No such work exists for id: #{object.id}"
          next
        else
          ActiveFedora::Base.find(object.id).update_index
          count += 1
        end
      end
    end
    puts "Reindexed works for #{count} objects"
  end
end
