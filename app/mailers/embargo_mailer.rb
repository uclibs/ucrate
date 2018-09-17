# frozen_string_literal: true

class EmbargoMailer < ActionMailer::Base
  def notify(email, doc_name, days_left)
    @work_title = doc_name
    @days_left = days_left
    mail(from: t('hyrax.product_email'),
         to: [email, t('hyrax.product_email')],
         subject: 'Embargoed Work Reminder')
  end
end
