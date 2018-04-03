module Hyrax
  class UploadsController < ApplicationController
    load_and_authorize_resource class: Hyrax::UploadedFile

    def create
      @upload.attributes = { file: params[:files].first,
                             user: current_user }
      @upload.save!
    rescue ActiveRecord::RecordInvalid
      render json: { files: [{ name: @upload.file.filename, size: @upload.file.size, error: @upload.errors[:base].first }] }
    end

    def destroy
      @upload.destroy
      head :no_content
    end
  end
end
