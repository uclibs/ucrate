# config/initializers/redis_config.rb
# frozen_string_literal: true

require 'redis'

unless Redis.respond_to?(:current=)
  class << Redis
    attr_accessor :current
  end
end

config = YAML.safe_load(ERB.new(IO.read(Rails.root.join('config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
Redis.current = Redis.new(url: config[:url])
