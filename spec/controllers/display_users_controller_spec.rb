# frozen_string_literal: true
require 'rails_helper'

describe DisplayUsersController, type: :controller do
  let!(:user) { FactoryBot.create(:user, first_name: "Robert") }

  context 'search for a user' do
    it 'works when you add trailing whitespace' do
      users = controller.search("Robert ")
      expect(users.count).to eq 1
    end
  end
end
