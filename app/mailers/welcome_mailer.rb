# frozen_string_literal: true

class WelcomeMailer < ActionMailer::Base
  default from: 'scholar@uc.edu'
  def welcome_email(user)
    @user = user
    if @user.student?
      @subject = 'Welcome to Scholar@UC, UC students!'
      @template = 'welcome_email_student.html.erb'
    else
      @subject = 'Welcome to Scholar@UC!'
      @template = 'welcome_email.html.erb'
    end
    send_mail
  end

  def send_mail
    mail(
      to: @user.email,
      subject: @subject,
      template_name: @template
    )
  end
end
