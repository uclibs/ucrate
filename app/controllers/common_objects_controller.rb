# frozen_string_literal: true

class CommonObjectsController < ApplicationController
  def show
    curation_concern ||= ActiveFedora::Base.find(params[:id], cast: true)

    if curation_concern.class == Collection
      redirect_to Hyrax::Engine.routes.url_helpers.polymorphic_path(curation_concern)
    else
      redirect_to polymorphic_path(curation_concern)
    end

  rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone
    render file: 'errors/not_found', status: :not_found
  end
end
