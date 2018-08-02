# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Dashboard::ProfilesController do
  let(:user) { create(:user) }
  routes { Hyrax::Engine.routes }

  before do
    sign_in user
    allow(controller).to receive(:clear_session_user) ## Don't clear out the authenticated session
  end

  it "redirects dashboard profile to user profile" do
    get :show, params: { id: user.user_key }
    expect(response).to redirect_to "/users/#{user.user_key.gsub('.', '-dot-')}?locale=en"
  end

  it "redirects to root if user does not exist" do
    expect do
      get :show, params: { id: 'johndoe666' }
    end.to raise_error ActiveRecord::RecordNotFound
  end
end
