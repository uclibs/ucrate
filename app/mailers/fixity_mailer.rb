# frozen_string_literal: true

class FixityMailer < ApplicationMailer
  default from: 'scholar@uc.edu'
  def fixity_email(user, subject, message)
    @user = user
    @message = message
    @subject = subject

    send_mail
  end

  def send_mail
    mail(
      to: @user.email,
      subject: @subject,
      body: @message
    )
  end
end
