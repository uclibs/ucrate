# frozen_string_literal: true
require 'oauth2'
require 'signet/oauth_2/client'
require Hyrax::Engine.root.join('app/services/hyrax/analytics/google.rb')
module Hyrax
  module Analytics
    module Google
      class Config
        def self.load_from_yaml
          filename = Rails.root.join('config', 'analytics.yml')
          yaml = YAML.safe_load(ERB.new(File.read(filename)).result)
          unless yaml
            Rails.logger.error("Unable to fetch any keys from #{filename}.")
            return new({})
          end
          new yaml.fetch('analytics')
        end
      end
    end
  end
end
