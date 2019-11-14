# frozen_string_literal: true

class ApiUploadsController < Hyrax::UploadsController
  # method override to catch virus validation failure and return message via json
  def self.create(given_user, upload_file)
    # Upload_file should be a ActionDispatch file
    @upload = Hyrax::UploadedFile.new
    @upload.attributes = { file: upload_file,
                           user: given_user }
    @upload.save!
  rescue ActiveRecord::RecordInvalid
    render json: { files: [{ name: @upload.file.filename, size: @upload.file.size, error: @upload.errors[:base].first }] }
  end
end
