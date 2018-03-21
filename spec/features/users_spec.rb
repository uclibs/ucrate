require 'rails_helper'

RSpec.describe "User Profile", type: :feature, clean_repo: true do
  before do
    sign_in user
  end
  let(:user) { create(:user) }
  let(:profile_path) { Hyrax::Engine.routes.url_helpers.user_path(user, locale: 'en') }
  let(:users_path) { Hyrax::Engine.routes.url_helpers.users_path }

  context 'when visiting user profile with highlighted works' do
    let(:work) { create(:work, user: user) }

    before do
      user.trophies.create!(work_id: work.id)
    end

    it 'page should be editable' do
      visit profile_path
      expect(page).to have_content(user.email)

      within '.highlighted-works' do
        expect(page).to have_link(work.to_s)
      end

      within '.panel-user' do
        click_link 'Edit Profile'
      end
      fill_in 'user_twitter_handle', with: 'curatorOfData'
      click_button 'Save Profile'
      expect(page).to have_content 'Your profile has been updated'
      expect(page).to have_link('curatorOfData', href: 'http://twitter.com/curatorOfData')
    end
  end

  context 'user profile' do
    let!(:dewey) { create(:user, display_name: 'Melvil Dewey') }
    let(:dewey_path) { Hyrax::Engine.routes.url_helpers.user_path(dewey, locale: 'en') }
    let!(:work) { FactoryBot.create(:work, user: user) }
    let!(:work2) { FactoryBot.create(:work, user: dewey) }

    it 'is searchable' do
      visit users_path
      expect(page).to have_xpath("//td/a[@href='#{profile_path}']")
      expect(page).to have_xpath("//td/a[@href='#{dewey_path}']")
      fill_in 'user_search', with: 'Dewey'
      click_button "user_submit"
      expect(page).not_to have_xpath("//td/a[@href='#{profile_path}']")
      expect(page).to have_xpath("//td/a[@href='#{dewey_path}']")
    end
  end

  context 'when editing user' do
    it 'renders identity and contact fields' do
      visit profile_path
      click_link('Edit Profile', match: :first)
      expect(page).to have_field('First Name', with: user.first_name)
      expect(page).to have_field('Last Name', with: user.last_name)
    end
  end

  context 'when the user is an admin' do
    before do
      admin = Role.create(name: "admin")
      admin.users << user
      admin.save
    end

    it 'includes the user without works in the display' do
      visit users_path
      expect(page).to have_xpath("//td/a[@href='#{profile_path}']")
    end
  end

  context 'when the user owns works' do
    let!(:work) { FactoryBot.create(:work, user: user) }

    it 'includes the user in the display' do
      visit users_path
      expect(page).to have_xpath("//td/a[@href='#{profile_path}']")
    end
  end

  context "when the user doesn't own works" do
    let!(:user_with_no_works) { create(:user) }
    let(:profile2_path) { Hyrax::Engine.routes.url_helpers.user_path(user_with_no_works, locale: 'en') }

    it 'does not include the user in the display' do
      visit users_path
      expect(page).not_to have_xpath("//td/a[@href='#{profile2_path}']")
    end
  end
end
