# frozen_string_literal: true

require Hyrax::Engine.root.join('app/models/job_io_wrapper.rb')

class JobIoWrapper < ApplicationRecord
  private

    def extracted_original_name
      eon = uploaded_file.uploader.filename if uploaded_file
      eon ||= file_set_filename
      eon ||= File.basename(path) if path.present? # note: uploader.filename is `nil` with uncached remote files (e.g. AWSFile)
      eon
    end

    def file_set_filename
      return unless file_set.import_url.present?
      # This is a cloud resource
      resourcename = HTTParty.get(file_set.import_url).header['content-disposition']
      resourcename.split('"')[1]
    end
end
