#!/usr/bin/env ruby
# frozen_string_literal: true

# Enforces docs/local/uc-hyku-customizations.manifest.yml against the repo.
# See lib/uc/hyku_customizations_inventory.rb
#
# Usage:
#   ruby scripts/ci/check_uc_customizations.rb

require_relative '../../lib/uc/hyku_customizations_inventory'

result = Uc::HykuCustomizationsInventory.new.call

unless result.ok
  warn 'UC customizations check failed:'
  result.errors.each { |message| warn "  - #{message}" }
  warn ''
  warn 'Update docs/local/uc-hyku-customizations.md and'
  warn 'docs/local/uc-hyku-customizations.manifest.yml (see the doc header).'
  exit 1
end

puts 'UC customizations check passed.'
puts "  inventory: #{result.inventory_doc}"
puts "  entries: #{result.entries_count}"
puts "  watched files covered: #{result.watched_count}"
