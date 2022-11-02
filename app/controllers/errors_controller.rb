# frozen_string_literal: true
class ErrorsController < ApplicationController
  def not_found
    render(status: :not_found)
  end

  def server_error
    render(status: :internal_server_error)
  end

  def unprocessable
    render(status: :unprocessable_entity)
  end
end
