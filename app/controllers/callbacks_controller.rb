# frozen_string_literal: true

class CallbacksController < Devise::OmniauthCallbacksController
  def shibboleth
    if current_user
      redirect_to Hyrax::Engine.routes.url_helpers.dashboard_path
    else
      retrieve_shibboleth_attributes
      create_or_update_user
      sign_in_shibboleth_user
    end
  end

  private

    def retrieve_shibboleth_attributes
      @omni = request.env["omniauth.auth"]
      @email = use_uid_if_email_is_blank
    end

    def create_or_update_user
      if user_exists?
        update_shibboleth_attributes if user_has_never_logged_in?
      else
        create_user
        send_welcome_email
      end
    end

    def sign_in_shibboleth_user
      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      cookies[:login_type] = "shibboleth"
      flash[:notice] = "You are now signed in as #{@user.name} (#{@user.email})"
    end

    def use_uid_if_email_is_blank
      # If user has no email address use their sixplus2@uc.edu instead
      # Some test accounts on QA/dev don't have email addresses
      @email = if defined?(@omni.extra.raw_info.mail)
                 return @omni.uid if @omni.extra.raw_info.mail.presence || @omni.uid
                 raise 'User does not have an email address or uid'
               else
                 @omni.uid
               end
    end

    def user_exists?
      @user = find_by_provider_and_uid
      return true unless @user.nil?
    end

    def find_by_provider_and_uid
      User.where(provider: @omni['provider'], uid: @omni['uid']).first
    end

    def update_shibboleth_attributes
      update_user_shibboleth_attributes
    end

    def user_has_never_logged_in?
      @user.sign_in_count.zero?
    end

    def create_user
      @user = User.create provider: @omni.provider,
                          uid: @omni.uid,
                          email: @email,
                          password: Devise.friendly_token[0, 20]
      update_user_shibboleth_attributes
    end

    def update_user_shibboleth_attributes
      @user.first_name         = @omni.extra.raw_info.givenName
      @user.last_name          = @omni.extra.raw_info.sn
      @user.save
    end

    def send_welcome_email
      # WelcomeMailer.welcome_email(@user).deliver
    end
end
