# frozen_string_literal: true

require Hyrax::Engine.root.join('app/controllers/hyrax/uploads_controller.rb')

module Hyrax
  class UploadsController < ApplicationController
    # method override to catch virus validation failure and return message via json
    def create
      @upload.attributes = { file: params[:files].first,
                             user: current_user }
      @upload.save!
    rescue ActiveRecord::RecordInvalid
      render json: { files: [{ name: @upload.file.filename, size: @upload.file.size, error: @upload.errors[:base].first }] }
    end
  end
end
