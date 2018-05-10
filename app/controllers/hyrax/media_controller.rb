# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Medium`
module Hyrax
  # Generated controller for Medium
  class MediaController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Medium

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::MediumPresenter
  end
end
