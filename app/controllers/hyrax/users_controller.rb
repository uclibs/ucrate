# frozen_string_literal: true

require Hyrax::Engine.root.join('app/controllers/hyrax/users_controller.rb')
module Hyrax
  class UsersController < ApplicationController
    include Blacklight::SearchContext
    def user_work_count(user)
      Hyrax::WorkRelation.new.where(DepositSearchBuilder.depositor_field => user.user_key).count
    end

    def show
      user = ::User.from_url_component(params[:id])
      return redirect_to root_path, alert: "User '#{params[:id]}' does not exist" if user.nil?
      @presenter = Hyrax::UserProfilePresenter.new(user, current_ability)
      @permalinks_presenter = PermalinksPresenter.new(hyrax.user_path(user, locale: nil))
    end
  end
end
