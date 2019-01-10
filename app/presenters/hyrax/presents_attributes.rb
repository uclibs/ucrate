# frozen_string_literal: true
require Hyrax::Engine.root.join('app/presenters/hyrax/presents_attributes.rb')
module Hyrax
  module PresentsAttributes
    def submitter_profile
      user = ::User.find_by_email(depositor)
      path = Hyrax::Engine.routes.url_helpers.dashboard_profile_path(user)
      "<dt>#{I18n.t('blacklight.search.fields.show.submitter')}</dt><dd><ul class=\"tabular\"><span class=\"attribute attribute-submitter\" itemprop=\"submitter\" itemscope itemtype=\"http://schema.org/Person\"><a href=\"#{path}\">#{user.name}</a></span></ul></dd>"
    end
  end
end
