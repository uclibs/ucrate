# frozen_string_literal: true
module ChangeManager
  class EmailManager
    extend ChangeManager::Manager

    def self.queue_change(owner, change_type, context, target)
      change_id = Change.new_change(owner, change_type, context, target)
      ChangeManager::ProcessChangeJob.set(wait: 15.minutes).perform_later(change_id)
    end

    def self.skip_sidekiq_for_emails(owner, change_type, context, target)
      # NOTE: For some reason, it duplicates the items in the final email, but only when not using sidekiq
      change_id = Change.new_change(owner, change_type, context, target)
      process_change change_id
    end

    def self.process_change(change_id)
      change = Change.find change_id
      return if change.cancelled?
      verified_changes = process_changes_similar_to change
      notify_target_of verified_changes unless verified_changes.empty?
      true
    end

    def self.notify_target_of(changes)
      grouped_changes = group_changes(changes)
      if grouped_changes['proxies']
        grouped_changes['proxies'].each(&:notify) if ChangeManager::ScholarNotificationMailer.notify_changes(grouped_changes['proxies']).deliver
      end

      return unless grouped_changes['editors']
      grouped_changes['editors'].each(&:notify) if ChangeManager::ScholarNotificationMailer.notify_changes(grouped_changes['editors']).deliver
    end

    def self.group_changes(changes)
      proxy_changes = []
      editor_changes = []
      changes.each do |change|
        if change.proxy_change?
          proxy_changes << change
        elsif change.editor_change?
          editor_changes << change
        end
      end
      grouped_changes = {}
      grouped_changes['proxies'] = proxy_changes unless proxy_changes.empty?
      grouped_changes['editors'] = editor_changes unless editor_changes.empty?
      grouped_changes
    end
  end
end
