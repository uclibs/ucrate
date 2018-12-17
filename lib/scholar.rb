# frozen_string_literal: true
module Scholar
  delegate :application_root_url, to: :configuration

  def self.permanent_url_for(object)
    File.join(Rails.configuration.application_root_url, 'show', object.id)
  end
end
