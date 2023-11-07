# frozen_string_literal: true

desc 'Starts EmbargoWorker to manage expired embargoes'
task embargo_notify: :environment do
  # Controls when reminder emails are sent out for expiring embargoed works.
  fourteen_days = 14
  thirty_days = 30
  one_day = 1
  zero_days = 0
  results_cap = 1_000_000
  Time.zone = 'EST'

  solr_results = ActiveFedora::SolrService.query('embargo_release_date_dtsi:[* TO *]', rows: results_cap)
  solr_results.each do |work|
    days_until_release = (Date.parse(work['embargo_release_date_dtsi']) - Time.zone.today).to_i

    receiver = work['depositor_tesim']
    mail_contents = work['title_tesim'].first

    case days_until_release
    when one_day # notify at end of day (~midnight), one day prior to release
      EmbargoMailer.notify(receiver, mail_contents, zero_days).deliver # still pass zero day count to mailer for notification message
    when fourteen_days
      EmbargoMailer.notify(receiver, mail_contents, fourteen_days).deliver
    when thirty_days
      EmbargoMailer.notify(receiver, mail_contents, thirty_days).deliver
    end
  end
end
