# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a Collection', js: true do
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end
    let!(:user_collection_type) { create(:user_collection_type) }
    let!(:user_collection) do
      create(:public_collection,
             user: user,
             description: ['collection description'],
             collection_type_settings: :nestable)
    end
    let!(:user_work) do
      create(:work, title: ["King Louie"], member_of_collections: [user_collection], user: user)
    end

    before do
      login_as user

      visit Hyrax::Engine.routes.url_helpers.new_dashboard_collection_path

      sleep 5

      title_element = find_by_id("collection_title")
      title_element.set("My Test Collection  ") # Add whitespace to test it getting removed

      select 'Attribution-ShareAlike 4.0 International', from: 'collection_license'

      fill_in('Creator', with: 'Doe, Jane')
      fill_in('Description', with: 'This is a description.')

      click_on('Save')
    end

    it do
      expect(page).to have_content('My Test Collection')
      expect(page).to have_selector("input[value='Doe, Jane']")
      expect(page).to have_field("Description", with: 'This is a description.')
      expect(page).to have_content "Collection was successfully created."

      id = page.current_path[23..58]
      visit "/dashboard/collections/#{id}"

      expect(page).to have_content('My Test Collection')
      expect(page).to have_content('Doe, Jane')
      expect(page).to have_content('This is a description.')
      expect(page).to have_link("Attribution-ShareAlike 4.0 International", href: 'http://creativecommons.org/licenses/by-sa/4.0/')
      expect(page).to have_content('Open Access')
      expect(page).to have_content('Items in this Collection')

      visit "/collections/#{user_collection.id}"
      expect(page).to have_content('Items in this Collection')
    end
  end
end
