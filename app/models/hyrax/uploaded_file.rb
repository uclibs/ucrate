# Copied from hyrax 366d146

module Hyrax
  # Store a file uploaded by a user. Eventually these files get
  # attached to FileSets and pushed into Fedora.

  class CheckVirusValidator < ActiveModel::Validator
    def validate(record)
      return true unless Hydra::Works::VirusCheckerService.file_has_virus?(record.file)
      record.errors[:base] << "Virus detected in file"
    end
  end

  class UploadedFile < ActiveRecord::Base
    self.table_name = 'uploaded_files'
    mount_uploader :file, UploadedFileUploader
    alias uploader file
    validates_with CheckVirusValidator
    has_many :job_io_wrappers,
             inverse_of: 'uploaded_file',
             class_name: 'JobIoWrapper',
             dependent: :destroy
    belongs_to :user, class_name: '::User'

    before_destroy :remove_file!
  end
end
