# frozen_string_literal: true
# helper for the WorksControllerBehavior class
# cleaner to keep all change manager code in here
module ChangeManager
  module ChangeManagerHelper
    def queue_notifications_for_editors(editors)
      editors.each do |editor_wrapper|
        editor = editor_wrapper[1]
        EmailManager.queue_change(curation_concern.depositor, action(editor), curation_concern.id, editor['name']) if changed? editor
      end
    rescue NotImplementedError
      editors.each do |editor_wrapper|
        editor = editor_wrapper[1]
        EmailManager.skip_sidekiq_for_emails(curation_concern.depositor, action(editor), curation_concern.id, editor['name']) if changed? editor
      end
    end

    private

      def removed_user_name_and_id
        # the to_s_u method must be implemented for every model
        permissions_ids = params.to_unsafe_hash[curation_concern.class.to_s_u][:permissions_attributes]
        return if permissions_ids.blank?
        permissions_ids.each do |permissions_id|
          permissions_id[1][:name] = agent_name(permissions_id) if removed_editor? permissions_id[1]
        end
        permissions_ids
      end

      def new_editor?(editor)
        edit_access?(editor) && name_key?(editor)
      end

      def removed_editor?(editor)
        editor['_destroy'] == 'true'
      end

      def name_key?(hash)
        hash.key? 'name'
      end

      def edit_access?(hash)
        hash.key?('access') && hash['access'] == 'edit'
      end

      def action(editor)
        if new_editor?(editor)
          "added_as_editor"
        elsif removed_editor?(editor)
          "removed_as_editor"
        end
      end

      def changed?(editor)
        new_editor?(editor) || removed_editor?(editor)
      end

      def agent_name(permissions_id)
        ActiveFedora::Base.find(permissions_id[1][:id]).agent_name
      end
  end
end
