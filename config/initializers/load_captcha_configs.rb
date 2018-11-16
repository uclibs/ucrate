# frozen_string_literal: true

CAPTCHA_SERVER = YAML.safe_load(ERB.new(File.read(Rails.root.join('config', 'recaptcha.yml'))).result)[Rails.env]
