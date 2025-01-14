# frozen_string_literal: true
# config/initializers/redlock_patch.rb
module Redlock
  class Client
    def call_with_redis_namespace_fix(redis, command, *args)
      # Ensure 'call' isn't used when redis-namespace is involved
      if redis.respond_to?(:namespace) && command == :call
        redis.client.call(*args)
      else
        redis.public_send(command, *args)
      end
    end

    def lock(resource, ttl, _options = {})
      @servers.each do |server|
        call_with_redis_namespace_fix(server, :set, resource, "LOCKED", "NX", "PX", ttl)
      end
      # ... other operations
    end

    def unlock(resource)
      @servers.each do |server|
        call_with_redis_namespace_fix(server, :del, resource)
      end
    end
  end
end
