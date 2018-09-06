# frozen_string_literal: true

Kaltura.configure do |config|
  config.partner_id = ENV["SCHOLAR_BROWSE_EVERYTHING_KALTURA_ID"]
  config.administrator_secret = ENV["SCHOLAR_BROWSE_EVERYTHING_KALTURA_SECRET"]
  config.service_url = 'https://www.kaltura.com'
end
