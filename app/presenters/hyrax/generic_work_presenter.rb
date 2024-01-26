# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work GenericWork`
module Hyrax
  class GenericWorkPresenter < Hyrax::WorkShowPresenter
    delegate :college, :department, :alternate_title, :alternate_title, :abstract, :right_notes, :access_rights, :time_period, :required_software, :note, :geo_subject, 
:doi, to: :solr_document
  end
end
