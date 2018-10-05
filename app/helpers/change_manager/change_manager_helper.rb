# frozen_string_literal: true
# helper for the WorksControllerBehavior class
# cleaner to keep all change manager code in here
module ChangeManager
  module ChangeManagerHelper
    def queue_notifications_for_editors(editors)
      editors.each do |editor_wrapper|
        editor = editor_wrapper[1]
        EmailManager.queue_change(curation_concern.depositor, 'added_as_editor', curation_concern.id, editor['name']) if new_editor? editor
        # uncomment this once the `Ldp::Gone` error is resolved
        # elsif removed_editor? editor
        #   EmailManager.queue_change(curation_concern.depositor, 'removed_as_editor', curation_concern.id, editor[:name])
        # end
      end
    rescue NotImplementedError
      editors.each do |editor_wrapper|
        editor = editor_wrapper[1]
        EmailManager.skip_sidekiq_for_emails(curation_concern.depositor, 'added_as_editor', curation_concern.id, editor['name']) if new_editor? editor
        # uncomment this once the `Ldp::Gone` error is resolved
        # elsif removed_editor? editor
        #   EmailManager.skip_sidekiq_for_emails(curation_concern.depositor, 'removed_as_editor', curation_concern.id, editor['name'])
        # end
      end
    end

    private

      def new_editor?(editor)
        edit_access?(editor) && name_key?(editor)
      end

      # implement once Ldp::Gone error is resolved
      # def removed_editor?(_editor)
      #   false
      # end

      def name_key?(hash)
        hash.key? 'name'
      end

      def edit_access?(hash)
        hash.key?('access') && hash['access'] == 'edit'
      end
  end
end
