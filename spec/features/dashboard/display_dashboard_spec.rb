require 'rails_helper'

RSpec.describe "The dashboard as viewed by a regular user", type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in user
    visit '/dashboard'
  end

  context "upon sign-in" do
    it "shows the user's information" do
      expect(page).to have_content "My Dashboard"
      expect(page).to have_content "User Activity"
      expect(page).to have_content "User Notifications"

      within '.sidebar' do
        expect(page).to have_link "Works"
        expect(page).to have_link "Collections"
      end
    end
  end
end
