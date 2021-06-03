# frozen_string_literal: true
Rails.application.config.xray = {
  name: "Scholar-#{Rails.env}@uc",
  patch: %I[net_http aws_sdk],
  # record db transactions as subsegments
  active_record: true,
  context_missing: 'LOG_ERROR',
  # Makes sure the log file size does not go beyond a size, beyond which it is rotated.
  # Only the latest rotated log will be retained. That is, the max possible size on disk of log files,
  # if `SCHOLAR_XRAY_MAX_LOG_SIZE` is set to 10, would be 10MB(for the actual log) + 10MB(for the latest rotated log).
  logger: Logger.new("log/#{Rails.env}-xray.log", 1, Integer(ENV.fetch("SCHOLAR_XRAY_MAX_LOG_SIZE", "10"), 10).megabytes)
  stream_threshold: 1,
}
