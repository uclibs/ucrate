require 'rails_helper'

describe "Users Spec", type: :feature do
  describe "User Profile", type: :feature, clean_repo: true do
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
        expect(page).to have_field('Job title', with: user.title)
        expect(page).to have_field('Department', with: user.ucdepartment)
        expect(page).to have_field('UC affiliation', with: user.uc_affiliation)
        expect(page).to have_field('Alternate email', with: user.alternate_email)
        expect(page).to have_field('Campus phone number', with: user.telephone)
        expect(page).to have_field('Alternate phone number', with: user.alternate_phone_number)
        expect(page).to have_field('Personal webpage', with: user.website)
        expect(page).to have_field('Blog', with: user.blog)
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

  describe "People Page", type: :feature, js: true do
    let!(:user) { create(:user) }
    let!(:user1) { create(:user, display_name: 'Alpha, Alpha', last_name: 'Alpha') }
    let!(:user2) { create(:user, display_name: 'Zeta, Zeta', last_name: 'Zeta') }
    let(:profile_path) { Hyrax::Engine.routes.url_helpers.user_path(user) }
    let(:profile1_path) { Hyrax::Engine.routes.url_helpers.user_path(user1) }
    let(:profile2_path) { Hyrax::Engine.routes.url_helpers.user_path(user2) }
    let(:profiles_path) { Hyrax::Engine.routes.url_helpers.users_path }

    context "when the user doesn't own works" do
      before do
        visit profiles_path
      end

      it 'does not include the user in the display' do
        expect(page).not_to have_xpath("//td/a[@href='#{profile_path}?locale=en']")
      end
    end

    context "when the user owns works" do
      let!(:work1) { FactoryBot.create(:work, user: user1) }
      let!(:work2) { FactoryBot.create(:work, user: user2) }

      before do
        visit profiles_path
      end

      it 'includes the user in the display' do
        expect(page).to have_xpath("//td/a[@href='#{profile_path}?locale=en']")
      end
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
        expect(page).to have_xpath("//td/a[@href='#{profile_path}?locale=en']")
      end
    end
  end
end
