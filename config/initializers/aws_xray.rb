# frozen_string_literal: true
Rails.application.config.xray = {
  name: "Scholar-#{Rails.env}@uc",
  patch: %I[net_http aws_sdk],
  # record db transactions as subsegments
  active_record: true,
  context_missing: 'LOG_ERROR',
  # Makes sure the log file size does not go beyond 10MB, beyond which it is rotated.
  # Only the latest rotated log will be retained. That is, the max possible size on disk of log files
  # in this case would be 10MB(for actual log) + 10MB(for the latest rotated log)
  logger: Logger.new("log/#{Rails.env}-xray.log", 1, 10 * 1024 * 1024),
}
