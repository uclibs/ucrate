# frozen_string_literal: true
class ApplicationMailer < ActionMailer::Base
  default from: 'scholar@uc.edu'
  layout 'mailer'
end
