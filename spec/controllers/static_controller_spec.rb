
# frozen_string_literal: true

require 'rails_helper'
describe StaticController do
  describe '#login' do
    let(:user) { FactoryBot.create(:user) }

    before do
      controller.stub(:current_user).and_return(user)
    end
    it 'redirects to dashboard when already logged in' do
      get :login
      response.should redirect_to(Hyrax::Engine.routes.url_helpers.dashboard_path)
    end
  end
end
