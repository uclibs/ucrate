# frozen_string_literal: true
Rails.application.config.xray = {
  name: 'Scholar@uc',
  patch: %I[net_http aws_sdk],
  # record db transactions as subsegments
  active_record: true,
  context_missing: 'LOG_ERROR'
}


