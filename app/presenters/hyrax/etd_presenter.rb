# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  class EtdPresenter < Hyrax::WorkShowPresenter
    delegate :genre, :alternate_title, :time_period, :required_software, :note, :advisor, :geo_subject, to: :solr_document
  end
end
