# frozen_string_literal: true

# Hyku's config/initializers/sidekiq.rb merges `thread_safe: true` into Redis
# options (legacy redis gem API). Sidekiq 7 uses redis-client, which rejects
# that keyword (`unknown keyword: :thread_safe`).
#
# Preload for Sidekiq *and* any Rails command that talks to Redis via Sidekiq
# (db:setup / db:seed / rails server):
#   RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec rails db:seed
#   RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec sidekiq
#
# Removable when Hyku stops passing thread_safe (or Sidekiq ignores it).

module HykuLocalSidekiqRedisCompat
  module_function

  def apply!
    return if defined?(@applied) && @applied
    return unless defined?(Sidekiq::RedisClientAdapter)

    Sidekiq::RedisClientAdapter.class_eval do
      alias_method :client_opts_without_thread_safe_strip, :client_opts unless method_defined?(:client_opts_without_thread_safe_strip)

      def client_opts(options)
        opts = client_opts_without_thread_safe_strip(options)
        opts.delete(:thread_safe)
        opts.delete('thread_safe')
        opts
      end
    end

    @applied = true
  end
end

module Kernel
  alias hyku_sidekiq_redis_original_require require unless method_defined?(:hyku_sidekiq_redis_original_require)

  def require(path)
    result = hyku_sidekiq_redis_original_require(path)
    HykuLocalSidekiqRedisCompat.apply! if path.to_s.include?('sidekiq')
    result
  end
end
