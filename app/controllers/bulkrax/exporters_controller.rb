# frozen_string_literal: true

require_dependency "bulkrax/application_controller"
gem_dir = Gem::Specification.find_by_name("bulkrax").gem_dir
require "#{gem_dir}/app/controllers/bulkrax/exporters_controller.rb"

module Bulkrax
  class ExportersController < ApplicationController
    include Hyrax::ThemedLayoutController
    include Bulkrax::DownloadBehavior
    before_action :authenticate_user!
    before_action :ensure_admin!
    before_action :set_exporter, only: [:show, :edit, :update, :destroy]
    with_themed_layout 'dashboard'

    private

    def ensure_admin!
      authorize! :read, :admin_dashboard
    end
  end
end
