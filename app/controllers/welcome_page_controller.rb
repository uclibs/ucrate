# frozen_string_literal: true

class WelcomePageController < ApplicationController
  def index; end

  def create
    if user_just_waived_welcome_page?
      current_user.waive_welcome_page!
      redirect_to landing_page
      flash[:notice] = "Thanks! You can always find the welcome page in our help menus."
    else
      redirect_to landing_page
    end
  end

  def user_just_waived_welcome_page?
    params[:commit] == t('hyrax.welcome.waive_page')
  end

  def user_waived_welcome_page?
    current_user.waived_welcome_page
  end
  helper_method :user_waived_welcome_page?

  def skip_new_user_help?
    current_user.profile_update_not_required
  end
  helper_method :skip_new_user_help?

  def landing_page
    Hyrax::Engine.routes.url_helpers.root_path
  end
end
