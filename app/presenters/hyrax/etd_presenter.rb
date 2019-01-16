# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  class EtdPresenter < Hyrax::WorkShowPresenter
    delegate :college, :department, :genre, :alternate_title, :time_period, :required_software, :note, :advisor, :degree, :committee_member, :geo_subject, :etd_publisher, :doi, to: :solr_document
  end
end
