# frozen_string_literal: true
module ChangeManager
  module ComparisonConcern
    extend ActiveSupport::Concern

    def proxy_change?
      change_type == 'added_as_proxy' || change_type == 'removed_as_proxy'
    end

    def editor_change?
      change_type == 'added_as_editor' || change_type == 'removed_as_editor'
    end
  end
end
