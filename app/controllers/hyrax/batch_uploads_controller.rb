# frozen_string_literal: true

require Hyrax::Engine.root.join('app/controllers/hyrax/batch_uploads_controller.rb')

module Hyrax
  class BatchUploadsController < ApplicationController
    private

      # @param [String] klass the name of the Hyrax Work Class being created by the batch
      # @note Cannot use a proper Class here because it won't serialize
      def create_update_job(klass)
        operation = BatchCreateOperation.create!(user: current_user,
                                                 operation_type: "Batch Create")
        # ActionController::Parameters are not serializable, so cast to a hash
        BatchCreateJob.perform_later(current_user,
                                     params[:title].permit!.to_h,
                                     params[:uploaded_files],
                                     attributes_for_actor.to_h.merge!(model: klass),
                                     operation)
      end
  end
end
