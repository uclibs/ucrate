# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Article`
module Hyrax
  class ArticlePresenter < Hyrax::WorkShowPresenter
    delegate :alternate_title, :college, :department, :journal_title, :issn, :time_period, :required_software, :note, :geo_subject, :doi, to: :solr_document
  end
end
