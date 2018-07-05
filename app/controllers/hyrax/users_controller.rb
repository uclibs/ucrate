# frozen_string_literal: true

require Hyrax::Engine.root.join('app/controllers/hyrax/users_controller.rb')
module Hyrax
  class UsersController < ApplicationController
    include Blacklight::SearchContext
    def user_work_count(user)
      Hyrax::WorkRelation.new.where(DepositSearchBuilder.depositor_field => user.user_key).count
    end
  end
end
