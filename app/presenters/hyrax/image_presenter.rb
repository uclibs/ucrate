# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImagePresenter < Hyrax::WorkShowPresenter
    delegate :college, :department, :alternate_title, :date_photographed, :genre, :time_period, :required_software, :note, :cultural_context, to: :solr_document
  end
end
