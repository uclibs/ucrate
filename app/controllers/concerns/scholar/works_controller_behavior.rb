# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work GenericWork`

module Scholar
  module WorksControllerBehavior
    include ChangeManager::ChangeManagerHelper

    def create
      super
      # the to_s_u method must be implemented for every model
      editors = params.to_unsafe_hash[curation_concern.class.to_s_u][:permissions_attributes]
      queue_notifications_for_editors(editors) if editors
    end

    def update
      super
      # the to_s_u method must be implemented for every model
      editors = params.to_unsafe_hash[curation_concern.class.to_s_u][:permissions_attributes]
      queue_notifications_for_editors(editors) if editors
    end
  end
end
