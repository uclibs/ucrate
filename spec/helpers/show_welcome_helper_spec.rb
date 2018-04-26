# frozen_string_literal: true

require 'rails_helper'
# include Devise::TestHelpers

describe ShowWelcomeHelper, type: :helper do
  let(:current_user) { FactoryBot.create(:user) }

  before { sign_in current_user }
  context 'when the user is not a student' do
    it 'renders the welcome page' do
      expect(helper.show_welcome_page).to include('what-types-of-content-should-i-submit-to-scholaruc')
    end
  end

  context 'when the user is a student' do
    before do
      current_user.uc_affiliation = 'student'
      current_user.save
    end
    it 'renders the student welcome page' do
      expect(helper.show_welcome_page).to include('how-can-students-use-scholaruc')
    end
  end
end
