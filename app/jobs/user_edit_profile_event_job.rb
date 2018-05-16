# frozen_string_literal: true

# Log user profile edits to activity streams
class UserEditProfileEventJob < EventJob
  def perform(editor)
    @editor = editor
    super
  end

  def action
    @editor.update_column(:profile_update_not_required, true)
    "User #{link_to_profile @editor} has edited his or her profile"
  end
end
