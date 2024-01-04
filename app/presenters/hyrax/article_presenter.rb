# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Article`
module Hyrax
  class ArticlePresenter < Hyrax::WorkShowPresenter
    delegate :alternate_title, :alternative_title,:abstract,  :college, :department, :journal_title, :issn, :time_period, :required_software, :rights_notes, :note, :geo_subject, 
:doi, to: 
:solr_document
  end
end
