# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog searching', js: true, type: :feature do
  let(:user) { create(:user) }

  before do
    allow(User).to receive(:find_by_user_key).and_return(stub_model(User, twitter_handle: 'bob'))
    sign_in user
    visit '/catalog'
  end

  context 'with works', :clean_repo do
    let!(:jills_work) do
      create(:public_work, title: ["Jill's Research"], creator: ["Jill Doe"], subject: ["jills_subject"], college: "CEAS", department: "Other", language: ["English"], publisher: ["UC Libraries"])
    end

    let!(:jacks_work) do
      create(:public_work, title: ["Jack's Research"])
    end

    it 'performing a search and verifying facets' do
      within('#search-form-header') do
        fill_in('search-field-header', with: 'Research')
        click_button('Go')
      end
      expect(page).to have_content('Search Results')
      expect(page).to have_content(jills_work.title.first)
      expect(page).to have_content(jacks_work.title.first)
      expect(page).to have_selector('.facet-field-heading', text: 'Type of Work')
      expect(page).to have_selector('.facet-field-heading', text: 'Language')
      expect(page).to have_selector('.facet-field-heading', text: 'Publisher')
      expect(page).to have_selector('.facet-field-heading', text: 'College')
      expect(page).to have_selector('.facet-field-heading', text: 'Creator/Author')
      expect(page).to have_selector('.facet-field-heading', text: 'Subject')
    end
  end
end
