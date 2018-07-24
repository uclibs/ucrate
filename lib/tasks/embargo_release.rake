# frozen_string_literal: true

task :embargo_release, [:date] => [:environment] do |_t, args|
  date = args.fetch(:date, nil)
  expiration_date = if date
                      Date.parse(date)
                    else
                      Time.zone.today
                    end
  ExpirationService.call(expiration_date)
end
