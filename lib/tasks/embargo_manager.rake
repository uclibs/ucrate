# frozen_string_literal: true

namespace :embargo_manager do
  desc 'Starts EmbargoWorker to manage expired embargoes'
  task notify: :environment do
    # Controls when reminder emails are sent out for expiring embargoed works.
    FOURTEEN_DAYS = 14
    THIRTY_DAYS = 30
    ZERO_DAYS = 0
    results_cap = 1_000_000

    solr_results = ActiveFedora::SolrService.query('embargo_release_date_dtsi:[* TO *]', rows: results_cap)
    solr_results.each do |work|
      days_until_release = (Date.parse(work['embargo_release_date_dtsi']) - Time.zone.today).to_i

      receiver = work['depositor_tesim']
      mail_contents = work['title_tesim'].first

      case days_until_release
      when ZERO_DAYS
        EmbargoMailer.notify(receiver, mail_contents, ZERO_DAYS).deliver
      when FOURTEEN_DAYS
        EmbargoMailer.notify(receiver, mail_contents, FOURTEEN_DAYS).deliver
      when THIRTY_DAYS
        EmbargoMailer.notify(receiver, mail_contents, THIRTY_DAYS).deliver
      end
    end
  end

  task :release, [:date] => [:environment] do |_t, args|
    date = args.fetch(:date, nil)
    expiration_date = if date
                        Date.parse(date)
                      else
                        Time.zone.today
                      end
    ExpirationService.call(expiration_date)
  end
end
