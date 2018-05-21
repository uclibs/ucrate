# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  # Generated controller for Image
  class ImagesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Image

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ImagePresenter

    def show
      permalink_message = "Permanent link to this page"
      @permalinks_presenter = PermalinksPresenter.new(main_app.common_object_path(locale: nil), permalink_message)
    end
  end
end
