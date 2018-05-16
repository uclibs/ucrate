# frozen_string_literal: true

module ShowWelcomeHelper
  def show_welcome_page
    if current_user.present? && current_user.student?
      render "welcome_page/student_welcome_text"
    else
      render "welcome_page/welcome_text"
    end
  end
end
