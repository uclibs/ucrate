# frozen_string_literal: true

# UC-local sample works adapted from Scholar@UC develop db/seeds.rb.
# Requires stock Hyku db:seed first (tenant, admin set, workflows).
# Solr + Fedora must be running.
#
#   RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec rake uc:seed:samples
#
namespace :uc do
  namespace :seed do
    desc 'Create UC sample users/works adapted from develop seeds (Hyku-compatible)'
    task samples: :environment do
      result = Uc::SampleSeedService.call
      $stdout.puts
      $stdout.puts('=' * 60)
      case result.status
      when :skipped
        $stdout.puts('RESULT: OK — UC sample seeds already present (skipped).')
        $stdout.puts('This is success, not a failure. Nothing was changed.')
      when :created
        $stdout.puts('RESULT: OK — UC sample seeds completed successfully.')
        $stdout.puts("Sample account password: #{result.password}")
        $stdout.puts("Objects indexed: #{result.created_count}")
        $stdout.puts('Sign in with manydeposits@example.com (etc.) or INITIAL_ADMIN_*.')
      else
        $stdout.puts("RESULT: OK — #{result.status}")
      end
      $stdout.puts('=' * 60)
    rescue StandardError => e
      $stdout.puts
      $stdout.puts('=' * 60)
      $stdout.puts("RESULT: FAILED — #{e.class}: #{e.message}")
      $stdout.puts('=' * 60)
      raise
    end
  end
end
