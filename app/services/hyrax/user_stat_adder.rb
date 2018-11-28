# frozen_string_literal: true
module Hyrax
  class UserStatAdder
    def self.reset_user_stats
      delete_all_user_stats
      add_up_all_the_user_stats
    end

    class << self
      def delete_all_user_stats
        UserStat.destroy_all
      end

      def add_up_all_the_user_stats
        ::User.find_each do |user|
          stats = {}
          stats[:work_views] = total_work_views(user)
          stats[:file_views] = total_file_views(user)
          stats[:file_downloads] = total_file_downloads(user)

          create_user_stat(stats, user)
        end
      end

      def total_work_views(user)
        stats_array = WorkViewStat.where(user_id: user.id).collect(&:work_views)
        total = stats_array.inject(:+)

        return 0 if total.nil?
        total
      end

      def total_file_views(user)
        stats_array = FileViewStat.where(user_id: user.id).collect(&:views)
        total = stats_array.inject(:+)

        return 0 if total.nil?
        total
      end

      def total_file_downloads(user)
        stats_array = FileDownloadStat.where(user_id: user.id).collect(&:downloads)
        total = stats_array.inject(:+)

        return 0 if total.nil?
        total
      end

      def create_user_stat(stats, user)
        date = Time.zone.today
        user_stat = UserStat.new(user_id: user.id, date: date)

        user_stat.file_views = stats.fetch(:file_views, 0)
        user_stat.file_downloads = stats.fetch(:file_downloads, 0)
        user_stat.work_views = stats.fetch(:work_views, 0)

        user_stat.save!
      end
    end
  end
end
