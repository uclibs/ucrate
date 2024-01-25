# frozen_string_literal: true

require Hyrax::Engine.root.join('app/controllers/hyrax/homepage_controller.rb')
module Hyrax
  class HomePageController < ApplicationController
  # Adds Hydra behaviors into the application controller
     include Blacklight::SearchContext
     include Blacklight::SearchHelper
     include Blacklight::AccessControls::Catalog

     def create_work_presenter
       Hyrax::SelectTypeListPresenter.new(current_user)
     end
  
  end
end
