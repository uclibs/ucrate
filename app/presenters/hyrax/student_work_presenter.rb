# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work StudentWork`
module Hyrax
  class StudentWorkPresenter < Hyrax::WorkShowPresenter
    delegate :college, :department, :alternate_title, :genre, :time_period, :required_software, :note, :degree, :advisor, :geo_subject, :doi, to: :solr_document
  end
end
