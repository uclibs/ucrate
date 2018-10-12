# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::DepositorsController, type: :controller do
  routes { Rails.application.class.routes }
  let(:user) { create(:user) }
  let(:grantee) { create(:user) }

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
