# frozen_string_literal: true

require 'aws-xray-sdk'

class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  skip_after_action :discard_flash_if_xhr
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'
  protect_from_forgery with: :exception

  private

  # override devise helper and route to CC.new when parameter is set
  def after_sign_in_path_for(resource)
    cookies[:login_type] = {
      value: "local",
      secure: Rails.env.production?
    }
    if !resource.waived_welcome_page
      Rails.application.routes.url_helpers.welcome_page_index_path
    else
      Rails.application.routes.url_helpers.new_classify_concern_path
    end
  end

  def after_sign_out_path_for(_resource_or_scope)
    if cookies[:login_type] == "shibboleth"
      "/Shibboleth.sso/Logout?return=https%3A%2F%2F" + ENV['SCHOLAR_SHIBBOLETH_LOGOUT']
    else
      root_path
    end
  end

  def auth_shib_user!
    redirect_to login_path unless user_signed_in?
  end

  around_action :add_tracing_and_logging_metadata

  def add_tracing_and_logging_metadata
    XRay.recorder.current_segment.user = current_user.try(:id) || 0

    logger.tagged("CU: #{current_user.try(:id) || 'UnauthenticatedUser'}") do
      yield
    end
  end

end