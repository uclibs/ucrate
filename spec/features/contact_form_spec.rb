# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Sending an email via the contact form", type: :feature do
  let(:user) { create(:user) }

  describe "with unauthenticated user" do
    it "shows recaptcha dialog" do
      visit '/'
      click_link "Contact", match: :first
      expect(page).to have_css('div.g-recaptcha')
    end
  end

  describe "with authenticated user" do
    before { sign_in(user) }

    it "sends mail" do
      visit '/'
      click_link "Contact", match: :first
      expect(page).to have_content "Contact Form"
      fill_in "Your Name", with: "Test McPherson"
      fill_in "Your Email", with: "archivist1@example.com"
      fill_in "Message", with: "I am contacting you regarding ScholarSphere."
      fill_in "Subject", with: "My Subject is Cool"
      select "Depositing content", from: "Issue Type"
      click_button "Send"
      expect(page).to have_content "Thank you for your message!"
    end
  end
end
