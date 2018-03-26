# frozen_string_literal: true

class FeedController < ApplicationController
  layout false

  def index
    @works = params[:size] ? RssQueryHandler.run_solr_query(params[:size]) : RssQueryHandler.run_solr_query
  end
end
