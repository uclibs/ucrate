# frozen_string_literal: true

###
# This mailer makes many assumptions as to the content contained in changes. Take care to ensure these assumptions are met
# or create your own mailer that extends ChangeManager::NotificationMailer
####

require 'yaml'

module ChangeManager
  class ScholarNotificationMailer < ChangeManager::NotificationMailer
    def notify_changes(changes)
      @changes = changes
      @change_types ||= YAML.load_file(Rails.root.join('path', 'to'))
      subject = 'Changes to your ' + @change_types[changes.first.change_type]['print'] + ' status in UCrate.'
      mail(to: changes.first.target,
           from: 'UCrate.edu',
           subject: subject).deliver
    end
  end
end
