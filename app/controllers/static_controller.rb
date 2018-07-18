# frozen_string_literal: true

class StaticController < ApplicationController
  def about
    render "static/about"
  end

  def terms
    render "hyrax/static/terms"
  end

  def coll_policy
    render "static/coll_policy"
  end

  def format_advice
    render "static/format_advice"
  end

  def faq
    render "static/faq"
  end

  def documenting_data
    render "static/documenting_data_help"
  end

  def creators_rights
    render "static/creators_rights"
  end

  def student_work_help
    render "static/student_work_help"
  end

  def advisor_guidelines
    render "static/advisor_guidelines"
  end

  def student_instructions
    render "static/student_instructions"
  end

  def help
    render "static/help"
  end

  def doi_help
    render "static/doi_help"
  end

  def login
    if current_user
      redirect_to Hyrax::Engine.routes.url_helpers.dashboard_path
    elsif AUTH_CONFIG['shibboleth_enabled']
      render "static/login"
    else
      redirect_to new_user_session_path
    end
  end
end
