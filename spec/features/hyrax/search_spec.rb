# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'searching' do
  let(:user) { create :user }
  let(:subject_value) { 'mustache' }
  let!(:work) do
    create(:public_work,
           title: ["Toothbrush"],
           description: [subject_value],
           user: user)
  end

  let!(:collection) do
    create(:public_collection, title: ['collection title abc'], description: [subject_value], user: user, members: [work])
  end

  context "as a public user", :clean_repo do
    it "using the gallery view" do
      visit '/catalog'
      fill_in "search-field-header", with: "Toothbrush"
      click_button "search-submit-header"
      expect(page).to have_content "1 entry found"
      within "#search-results" do
        expect(page).to have_content 'Toothbrush'
      end

      click_link "Gallery"
      expect(page).to have_content "Filtering by: Toothbrush"
      within "#documents" do
        expect(page).to have_content 'Toothbrush'
      end
    end

    it "only searches all and does not display search options for dashboard files" do
      visit '/catalog'

      # it "does not display search options for dashboard files" do
      # This section was tested on its own, and required a full setup.
      within(".input-group-btn") do
        expect(page).not_to have_content("All")
        expect(page).not_to have_content("My Works")
        expect(page).not_to have_content("My Collections")
        expect(page).not_to have_content("My Shares")
      end
      # end

      expect(page).not_to have_css("a[data-search-label*=All]", visible: false)
      expect(page).not_to have_css("a[data-search-label*='My Works']", visible: false)
      expect(page).not_to have_css("a[data-search-label*='My Collections']", visible: false)
      expect(page).not_to have_css("a[data-search-label*='My Highlights']", visible: false)
      expect(page).not_to have_css("a[data-search-label*='My Shares']", visible: false)

      fill_in "search-field-header", with: subject_value
      click_button("Go")

      expect(page).to have_content('Search Results')
      expect(page).to have_content "Toothbrush"
      expect(page).to have_content('collection title abc')
      expect(page).to have_selector("//img")
    end

    it "displays browse button" do
      visit about_path
      expect(page).to have_link("Browse", href: "#{main_app.search_catalog_path}?locale=en")
    end
  end
end
