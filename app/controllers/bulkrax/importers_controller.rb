# frozen_string_literal: true

require_dependency 'bulkrax/application_controller'
require_dependency 'oai'
gem_dir = Gem::Specification.find_by_name("bulkrax").gem_dir
require "#{gem_dir}/app/controllers/bulkrax/importers_controller.rb"

module Bulkrax
  class ImportersController < ApplicationController
    include Hyrax::ThemedLayoutController
    include Bulkrax::DownloadBehavior
    include Bulkrax::API
    include Bulkrax::ValidationHelper

    protect_from_forgery unless: -> { api_request? }
    before_action :token_authenticate!, if: -> { api_request? }, only: [:create, :update, :delete]
    before_action :authenticate_user!, unless: -> { api_request? }
    before_action :ensure_admin!
    before_action :set_importer, only: [:show, :edit, :update, :destroy]
    with_themed_layout 'dashboard'

    private

      def ensure_admin!
        authorize! :read, :admin_dashboard
      end
  end
end
