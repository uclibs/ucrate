#!/usr/bin/env ruby
# frozen_string_literal: true

# Merge SimpleCov .resultset.json files from parallel CI shards into one report.
# Usage: bundle exec ruby scripts/ci/merge_coverage.rb [glob]
# Default glob: tmp/coverage_shards/*/.resultset.json

require 'json'
require 'simplecov'

glob = ARGV[0] || 'tmp/coverage_shards/**/.resultset.json'
files = Dir[glob].sort

if files.empty?
  warn "No SimpleCov resultsets matched #{glob}"
  exit 1
end

puts "Collating #{files.size} SimpleCov resultset(s):"
files.each { |f| puts "  #{f}" }

SimpleCov.collate(files, 'rails')

percent =
  if File.file?('coverage/.last_run.json')
    data = JSON.parse(File.read('coverage/.last_run.json'))
    raw = data.dig('result', 'line') || data.dig('result', 'covered_percent')
    format('%.2f', raw)
  else
    format('%.2f', SimpleCov.result.covered_percent)
  end

puts "Merged line coverage: #{percent}%"
File.write('coverage/merged_coverage.txt', "#{percent}\n")
