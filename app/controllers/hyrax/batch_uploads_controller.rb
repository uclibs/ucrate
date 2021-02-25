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

    # Hyrax override to check for presense and validity of payload_concern param
    def build_form
      super
      raise ActionController::RoutingError, 'Not Found' unless work_type_specified?
      @form.payload_concern = params[:payload_concern]
    end

    def work_type_specified?
      Hyrax.config.registered_curation_concern_types.include? params[:payload_concern]
    end
  end
end
