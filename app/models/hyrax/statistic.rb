# frozen_string_literal: true

require Hyrax::Engine.root.join('app/models/hyrax/statistic.rb')

module Hyrax
  class Statistic < ActiveRecord::Base
    def ga_statistics(start_date, object)
      path = if object.class.to_s == 'FileSet'
               hyrax_parent_file_set_path(object.parent, object)
             else
               polymorphic_path object
             end

      profile = Hyrax::Analytics.profile
      unless profile
        Rails.logger.error("Google Analytics profile has not been established. Unable to fetch statistics.")
        return []
      end
      profile.hyrax__pageview(sort: 'date', start_date: start_date).for_path(path)
    end
  end
end
