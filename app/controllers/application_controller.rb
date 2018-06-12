# frozen_string_literal: true

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
      cookies[:login_type] = "local"
      if !resource.waived_welcome_page
        Rails.application.routes.url_helpers.welcome_page_index_path
      else
        Hyrax::Engine.routes.url_helpers.root_path
      end
    end

    def after_sign_out_path_for(_resource_or_scope)
      if cookies[:login_type] == "shibboleth"
        "/Shibboleth.sso/Logout?return=https%3A%2F%2Fbamboo_shibboleth_logout"
      else
        root_path
      end
    end
end
