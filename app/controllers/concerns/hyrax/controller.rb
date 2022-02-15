# frozen_string_literal: true

require Hyrax::Engine.root.join('app/controllers/concerns/hyrax/controller.rb')

module Hyrax::Controller
  extend ActiveSupport::Concern

  def deny_access_for_anonymous_user(exception, json_message)
    session['user_return_to'] = request.url
    respond_to do |wants|
      wants.html { redirect_to main_app.login_path, alert: exception.message }
      wants.json { render_json_response(response_type: :unauthorized, message: json_message) }
    end
  end
end
