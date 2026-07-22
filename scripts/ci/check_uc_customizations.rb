#!/usr/bin/env ruby
# frozen_string_literal: true

# Enforces docs/local/uc-hyku-customizations.manifest.yml against the repo.
#
# Checks:
# 1) Every manifest entry path exists (unless allow_missing: true).
# 2) Every on-disk file matching watch_globs is covered by a manifest entry.
# 3) On pull_request (GITHUB_EVENT_NAME=pull_request): if the PR changes a
#    hyku_patched path or a watched customization file (other than docs/local/
#    prose), the inventory markdown must also change in the PR.
#
# Usage:
#   ruby scripts/ci/check_uc_customizations.rb
#   UC_CUSTOMIZATIONS_BASE_SHA=abc123 UC_CUSTOMIZATIONS_HEAD_SHA=def456 \
#     ruby scripts/ci/check_uc_customizations.rb

require 'pathname'
require 'yaml'
require 'english'

ROOT = Pathname.new(__dir__).join('../..').expand_path
MANIFEST_PATH = ROOT.join('docs/local/uc-hyku-customizations.manifest.yml')

def fail_with(messages)
  warn 'UC customizations check failed:'
  messages.each { |m| warn "  - #{m}" }
  warn ''
  warn 'Update docs/local/uc-hyku-customizations.md and'
  warn 'docs/local/uc-hyku-customizations.manifest.yml (see the doc header).'
  exit 1
end

def load_manifest
  fail_with(["Missing #{MANIFEST_PATH.relative_path_from(ROOT)}"]) unless MANIFEST_PATH.file?

  YAML.safe_load(MANIFEST_PATH.read, permitted_classes: [], aliases: false) || {}
end

def expand_glob(pattern)
  Dir.glob(ROOT.join(pattern).to_s, File::FNM_EXTGLOB).map do |abs|
    Pathname.new(abs).relative_path_from(ROOT).to_s
  end.reject { |p| p.end_with?('/') }
end

def covered_by_entry?(rel_path, entries)
  entries.any? do |entry|
    path = entry['path'].to_s
    if path.end_with?('/')
      rel_path == path.delete_suffix('/') || rel_path.start_with?(path)
    else
      rel_path == path
    end
  end
end

def git_changed_files(base_sha, head_sha)
  return [] if base_sha.to_s.empty? || head_sha.to_s.empty?

  out = `git -C #{ROOT} diff --name-only --diff-filter=ACMR #{base_sha}...#{head_sha} 2>/dev/null`
  return [] unless $CHILD_STATUS.success?

  out.split("\n").map(&:strip).reject(&:empty?)
end

manifest = load_manifest
entries = Array(manifest['entries'])
inventory_doc = manifest['inventory_doc'].to_s
watch_globs = Array(manifest['watch_globs'])
hyku_patched = Array(manifest['hyku_patched'])
errors = []

errors << "inventory_doc missing: #{inventory_doc}" unless ROOT.join(inventory_doc).file?

entries.each do |entry|
  path = entry['path'].to_s
  next if entry['allow_missing']
  next if path.empty?

  abs = ROOT.join(path.delete_suffix('/'))
  unless abs.exist?
    errors << "manifest entry missing on disk: #{path} (id=#{entry['id']})"
  end
end

watched_files = watch_globs.flat_map { |g| expand_glob(g) }.uniq.sort
undocumented = watched_files.reject { |f| covered_by_entry?(f, entries) }
undocumented.each do |f|
  errors << "watched file not listed in manifest entries: #{f}"
end

hyku_patched.each do |path|
  next if entries.any? { |e| e['path'].to_s == path && e['kind'].to_s == 'hyku_patched' }

  # Directory-style coverage is not used for hyku_patched list; require exact entry.
  unless entries.any? { |e| e['path'].to_s == path }
    errors << "hyku_patched path not registered in entries: #{path}"
  end
end

# PR change enforcement
event = ENV.fetch('GITHUB_EVENT_NAME', '')
base_sha = ENV['UC_CUSTOMIZATIONS_BASE_SHA'] || ENV['GITHUB_EVENT_PULL_REQUEST_BASE_SHA']
head_sha = ENV['UC_CUSTOMIZATIONS_HEAD_SHA'] || ENV['GITHUB_SHA']

# Actions sets GITHUB_EVENT_PATH; prefer explicit env from the workflow.
if event == 'pull_request' || ENV['UC_CUSTOMIZATIONS_ENFORCE_PR'] == '1'
  changed = git_changed_files(base_sha, head_sha)
  if changed.any?
    inventory_changed = changed.include?(inventory_doc) ||
                        changed.include?('docs/local/uc-hyku-customizations.manifest.yml')

    triggers = []
    changed.each do |file|
      next if file == inventory_doc
      next if file == 'docs/local/uc-hyku-customizations.manifest.yml'
      # Pure local-doc edits (other than inventory) do not require inventory churn.
      next if file.start_with?('docs/local/') && file != inventory_doc

      if hyku_patched.include?(file)
        triggers << file
        next
      end

      triggers << file if covered_by_entry?(file, entries) && !file.start_with?('docs/local/')
    end

    if triggers.any? && !inventory_changed
      errors << 'PR changes UC customizations but does not update ' \
                "#{inventory_doc} (or the manifest). Changed: #{triggers.sort.join(', ')}"
    end
  end
end

fail_with(errors) if errors.any?

puts 'UC customizations check passed.'
puts "  inventory: #{inventory_doc}"
puts "  entries: #{entries.size}"
puts "  watched files covered: #{watched_files.size}"
