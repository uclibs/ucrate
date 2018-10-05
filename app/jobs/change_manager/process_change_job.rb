# frozen_string_literal: true
require 'yaml'
module ChangeManager
  class ProcessChangeJob < ActiveJob::Base
    queue_as :change

    def perform(change_id)
      config_file ||= YAML.load_file(Rails.root.join('config', 'change_manager_config.yml'))
      config_file['manager_class'].constantize.process_change(change_id)
    end
  end
end
