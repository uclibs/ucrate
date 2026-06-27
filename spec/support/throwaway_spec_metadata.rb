# frozen_string_literal: true

# Throwaway slop specs (spec/throwaway/) run only via bin/rspec-fast — not in CI.
RSpec.configure do |config|
  config.filter_run_excluding throwaway: true unless ENV['SCHOLAR_FAST_SPECS'] == '1'
end
