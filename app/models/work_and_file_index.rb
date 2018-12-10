# frozen_string_literal: true
class WorkAndFileIndex < ApplicationRecord
  def update_stats_last_gathered
    self.stats_last_gathered = Time.zone.today
    save
  end

  def self.reset
    destroy_all
    index_works_and_files
  end

  def self.update_works_and_files
    index_new_works
    remove_deleted_works
    index_new_files
    remove_deleted_files
  end

  class << self
    def index_works_and_files
      all_works_with_users.each do |id, email|
        create_new_work_index_record(email, id)
      end

      all_files_with_users.each do |id, email|
        create_new_file_index_record(email, id)
      end
    end

    def index_new_works
      (all_works_with_users.keys - indexed_work_ids).each do |id|
        create_new_work_index_record(all_works_with_users[id], id)
      end
    end

    def index_new_files
      (all_files_with_users.keys - indexed_file_ids).each do |id|
        create_new_file_index_record(all_files_with_users[id], id)
      end
    end

    def remove_deleted_works
      (indexed_work_ids - all_work_ids).each do |id|
        work_index_entry = find_by(object_id: id)
        work_index_entry.destroy
      end
    end

    def remove_deleted_files
      (indexed_file_ids - all_file_ids).each do |id|
        file_index_entry = find_by(object_id: id)
        file_index_entry.destroy
      end
    end

    def indexed_work_ids
      where(object_type: "work").select("object_id").map(&:object_id)
    end

    def indexed_file_ids
      where(object_type: "file").select("object_id").map(&:object_id)
    end

    def all_works_with_users
      ids_with_users = {}
      Hyrax::WorkRelation.new.search_in_batches("*:*", fl: "id, depositor_ssim") do |group|
        group.each { |entry| ids_with_users[entry["id"]] = entry["depositor_ssim"].first }
      end
      ids_with_users
    end

    def all_work_ids
      all_works_with_users.map { |id, _user| id }
    end

    def all_files_with_users
      ids_with_users = {}
      ::FileSet.search_in_batches("*:*", fl: "id, depositor_ssim") do |group|
        group.each { |entry| ids_with_users[entry["id"]] = entry["depositor_ssim"].first }
      end
      ids_with_users
    end

    def all_file_ids
      all_files_with_users.map { |id, _user| id }
    end

    def create_new_work_index_record(user_email, id)
      create(user_email: user_email, object_id: id, object_type: "work")
    end

    def create_new_file_index_record(user_email, id)
      create(user_email: user_email, object_id: id, object_type: "file")
    end
  end
end
