# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work GenericWork`
module Hyrax
  class GenericWorkPresenter < Hyrax::WorkShowPresenter
    delegate :college, :department, :genre, :alternate_title, :time_period, :required_software, :note, to: :solr_document
  end
end
