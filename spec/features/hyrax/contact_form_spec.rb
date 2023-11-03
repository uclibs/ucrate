# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Sending an email via the contact form", type: :feature do
  describe "with Jot Iframe" do
    it "shows recaptcha dialog" do
      visit '/'
      click_link "Contact", match: :first
      expect(page).to have_css('iframe')
      expect(page.html).to include('</iframe>')
    end
  end
end
