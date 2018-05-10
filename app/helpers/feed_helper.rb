# frozen_string_literal: true

module FeedHelper
  def url_for_work(id)
    File.join Rails.configuration.application_root_url, 'show', id
  end
end
