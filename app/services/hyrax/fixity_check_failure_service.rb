# frozen_string_literal: true
module Hyrax
  class FixityCheckFailureService < AbstractMessageService
    attr_reader :log_date, :checksum_audit_log, :file_set

    def initialize(file_set, checksum_audit_log:)
      @file_set = file_set
      @checksum_audit_log = checksum_audit_log
      @log_date = checksum_audit_log.created_at
      user = select_notify_email
      FixityMailer.fixity_email(user, subject, message).deliver
      super(file_set, user)
    end

    def message
      uri = file_set.original_file.uri.to_s
      file_title = file_set.title.first
      I18n.t('hyrax.notifications.fixity_check_failure.message', log_date: log_date, file_title: file_title, uri: uri)
    end

    def subject
      I18n.t('hyrax.notifications.fixity_check_failure.subject')
    end

    def select_notify_email
      if ::User.find_by_user_key(ENV["FIXITY_NOTIFY_EMAIL"])
        ::User.find_by_user_key(ENV["FIXITY_NOTIFY_EMAIL"])
      else
        ::User.find_by_user_key(file_set.depositor)
      end
    end
  end
end
