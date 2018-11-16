# frozen_string_literal: true

AUTH_CONFIG = YAML.safe_load(ERB.new(File.read(Rails.root.join('config', 'authentication.yml'))).result)[Rails.env]
