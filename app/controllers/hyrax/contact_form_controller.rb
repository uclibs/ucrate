# frozen_string_literal: false

module Hyrax
  class ContactFormController < ApplicationController
    extend ActiveSupport::Concern
    before_action :build_contact_form
    FAIL_NOTICE = "You must complete the Captcha to confirm the form. ".freeze

    def new; end

    def create
      # not spam and a valid form
      if @contact_form.valid? && passes_captcha_or_is_logged_in?
        Hyrax::ContactMailer.contact(@contact_form).deliver_now
        flash.now[:notice] = 'Thank you for your message!'
        after_deliver
        @contact_form = ContactForm.new
      else
        flash.now[:error] = 'Sorry, this message was not sent successfully. '
        flash.now[:error] << FAIL_NOTICE
        flash.now[:error] << @contact_form.errors.full_messages.map(&:to_s).join(", ")
      end
      render :new
    rescue RuntimeError => exception
      handle_create_exception(exception)
    end

    def handle_create_exception(exception)
      logger.error("Contact form failed to send: #{exception.inspect}")
      flash.now[:error] = 'Sorry, this message was not delivered.'
      render :new
    end

    # Override this method if you want to perform additional operations
    # when a email is successfully sent, such as sending a confirmation
    # response to the user.
    def after_deliver; end

    def verify_google_recaptcha(_key, response)
      status = `curl "https://www.google.com/recaptcha/api/siteverify?secret=#{CAPTCHA_SERVER['_key']}&response=#{response}"`
      hash = JSON.parse(status)
      hash["success"] == true
    end

    protected

      def build_contact_form
        @contact_form = Hyrax::ContactForm.new(contact_form_params)
      end

      def contact_form_params
        return {} unless params.key?(:contact_form)
        params.require(:contact_form).permit(:contact_method, :category, :name, :email, :subject, :message)
      end

      def passes_captcha_or_is_logged_in?
        return true if current_user.present?
        verify_google_recaptcha(CAPTCHA_SERVER['secret_key'], params["g-recaptcha-response"])
      end
  end
end
