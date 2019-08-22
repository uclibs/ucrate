# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "User Spec", type: :feature do
  describe "User Profile", type: :feature do
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
        expect(page).not_to have_content("Joined on")
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

    context 'when editing user' do
      it 'renders identity and contact fields' do
        visit profile_path
        click_link('Edit Profile', match: :first)
        expect(page).to have_field('First Name', with: user.first_name)
        expect(page).to have_field('Last Name', with: user.last_name)
        expect(page).to have_field('Job title', with: user.title)
        expect(page).to have_field('Department', with: user.ucdepartment)
        expect(page).to have_field('UC affiliation', with: user.uc_affiliation)
        expect(page).to have_field('Alternate email', with: user.alternate_email)
        expect(page).to have_field('Campus phone number', with: user.telephone)
        expect(page).to have_field('Alternate phone number', with: user.alternate_phone_number)
        expect(page).to have_field('Research Directory webpage', with: user.rd_page)
        expect(page).to have_field('Personal webpage', with: user.website)
        expect(page).to have_field('Blog', with: user.blog)
        expect(page).to have_content('Create or Connect your ORCID iD')
      end

      it 'shows permalinks after editing' do
        visit profile_path
        click_link('Edit Profile', match: :first)
        click_on('Save Profile')
        expect(page).to have_content("Link to this page: ")
        expect(page).to have_content("/users/#{user.user_key.gsub('.', '-dot-')}")
        expect(page).to have_content("https://researchdirectory.uc.edu/p/user")
      end
    end
  end

  describe "People Page", type: :feature, js: true do
    let!(:user) { create(:user) }
    let!(:user1) { create(:user, display_name: 'Alpha, Alpha', last_name: 'Alpha') }
    let!(:user2) { create(:user, display_name: 'Zeta, Zeta', last_name: 'Zeta') }
    let(:profile_path) { Hyrax::Engine.routes.url_helpers.user_path(user, locale: 'en') }
    let(:profile1_path) { Hyrax::Engine.routes.url_helpers.user_path(user1, locale: 'en') }
    let(:profile2_path) { Hyrax::Engine.routes.url_helpers.user_path(user2, locale: 'en') }
    let(:profiles_path) { Hyrax::Engine.routes.url_helpers.users_path }

    it "has a Search People field label and placeholder text" do
      visit profiles_path
      expect(page).to have_css("label", text: "Search People")
      expect(page).to have_field(id: 'user_search', placeholder: "Search People")
    end

    context "when the user doesn't own works" do
      before do
        visit profiles_path
      end

      it 'does not include the user in the display' do
        expect(page).not_to have_xpath("//td/a[@href='#{profile_path}?locale=en']")
      end
    end

    context "when the user owns works" do
      let!(:work) { FactoryBot.create(:work, user: user) }
      let!(:work1) { FactoryBot.create(:work, user: user1) }
      let!(:work2) { FactoryBot.create(:work, user: user2) }

      before do
        visit profiles_path
      end

      it 'includes the user in the display' do
        expect(page).to have_xpath("//td/a[@href='#{profile_path}']")
        expect(page).to have_xpath("//td/a[@href='#{profile1_path}']")
      end

      context "allows user name sorting" do
        before do
          user1 # create the collections by referencing them
          user2
          sign_in user1
          visit profiles_path
        end

        it "has user name for people" do
          expect(page).to have_content(user1.last_name)
        end

        it "allows changing sort order" do
          expect(page).to have_content(user1.last_name)
          expect(page).to have_content(user2.last_name)

          default_order = User.order(:last_name).sort.map { |user| page.body.index(user.last_name) }
          expect(default_order).to eq(default_order.sort)

          find(:css, "#name").click

          expect(page).to have_content(user1.last_name)
          expect(page).to have_content(user2.last_name)

          post_click_order = User.order(:last_name).map { |user| page.body.index(user.last_name) }
          expect(post_click_order).to eq(post_click_order.sort!)
        end
      end
    end

    context "when the user owns works and is an admin (not logged in)" do
      let!(:work) { FactoryBot.create(:work, user: user) }

      before do
        admin = Role.create(name: "admin")
        admin.users << user
        admin.save
        visit profiles_path
      end

      it 'does not include the user in the display' do
        expect(page).not_to have_xpath("//td/a[@href='#{profile_path}?locale=en']")
      end
    end

    context "when the logged in user is an admin" do
      before do
        admin = Role.create(name: "admin")
        admin.users << user
        admin.save
        sign_in user
        visit profiles_path
      end

      it 'includes the user without works in the display' do
        expect(page).to have_xpath("//td/a[@href='#{profile_path}']")
      end
    end
  end
end
