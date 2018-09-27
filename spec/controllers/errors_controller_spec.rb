# frozen_string_literal: true
require 'rails_helper'
describe ErrorsController, type: :controller do
  describe '#show' do
    it 'renders the 404 error page when it receives a 404 status code' do
      get :not_found
      expect(response).to render_template('not_found')
    end
    it 'renders the 422 error page when it receives a 422 status code' do
      get :unprocessable
      expect(response).to render_template('unprocessable')
    end
    it 'renders the 500 error page when it receives a 500 status code' do
      get :server_error
      expect(response).to render_template('server_error')
    end
  end
end
