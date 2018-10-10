# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Dataset`
module Hyrax
  class DatasetPresenter < Hyrax::WorkShowPresenter
    delegate :college, :department, :alternate_title, :genre, :time_period, :required_software, :note, :geo_subject, to: :solr_document
  end
end
