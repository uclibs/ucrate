# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  def after_sign_up_path_for(resource)
    WelcomeMailer.welcome_email(resource).deliver
    after_sign_in_path_for(resource)
  end
end
