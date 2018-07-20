# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Document`
module Hyrax
  class DocumentPresenter < Hyrax::WorkShowPresenter
    delegate :college, :department, :alternate_title, :genre, :time_period, :required_software, :note, to: :solr_document
  end
end
