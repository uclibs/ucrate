# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::DepositorsController, type: :controller do
  routes { Rails.application.class.routes }
  let(:user) { create(:user) }
  let(:grantee) { create(:user) }

  describe "create" do
    let(:request_to_grant_proxy) { post :create, params: { user_id: user.user_key, grantee_id: grantee.user_key, format: 'json', use_route: :hyrax } }
    let(:expected_delete_path) { "/users/" + user.user_key.gsub("\.", '-dot-') + "/depositors/" + grantee.user_key.gsub("\.", '-dot-') + "?locale=en" }
    let(:bad_request_to_grant_proxy) { post :create, params: { user_id: user.user_key, grantee_id: user.user_key, format: 'json', use_route: :hyrax } }

    before do
      sign_in user
    end

    context "adding a proxy" do
      let(:request_to_grant_proxy) { post :create, params: { user_id: user.user_key, grantee_id: grantee.user_key, format: 'json', use_route: :hyrax } }
      let(:expected_delete_path) { "/users/" + user.user_key.gsub("\.", '-dot-') + "/depositors/" + grantee.user_key.gsub("\.", '-dot-') + "?locale=en" }

      it "is successful" do
        expect { request_to_grant_proxy }.to change { ProxyDepositRights.count }.by(1)
        expect(JSON.parse(response.body)["delete_path"]).to eq expected_delete_path
      end
    end

    context "fails when user adds themselves" do
      let(:request_to_grant_proxy) { post :create, params: { user_id: user.user_key, grantee_id: user.user_key, format: 'json', use_route: :hyrax } }
      let(:error_message) { "You can't be a proxy for yourself." }

      it "fails when user adds themself as a proxy" do
        expect { request_to_grant_proxy }.to change { ProxyDepositRights.count }.by(0)
        expect(JSON.parse(response.body)["error"]).to eq error_message
      end
    end
  end

  describe "destroy" do
    before do
      user.can_receive_deposits_from << grantee
      sign_in user
    end

    it "is successful" do
      expect { delete :destroy, params: { user_id: user.user_key, id: grantee.user_key, use_route: :hyrax } }.to change { ProxyDepositRights.count }.by(-1)
    end
  end
end
