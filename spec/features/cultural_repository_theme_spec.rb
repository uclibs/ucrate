# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin can select cultural repository theme', type: :feature, js: true, clean: true do
  let(:admin) { FactoryBot.create(:admin, email: 'admin@example.com', display_name: 'Adam Admin') }
  let(:user) { create :user }

  # rubocop:disable RSpec/LetSetup
  let!(:work) do
    create(:generic_work,
           title: ['Llamas and Alpacas'],
           keyword: ['llama', 'alpaca'],
           user:)
  end
  # rubocop:enable RSpec/LetSetup

  # Site is Apartment-tenanted; JS feature specs must assert themes via the app
  # (page / selects), not Site.instance in the test process.

  def save_home_theme(name)
    visit '/admin/appearance'
    click_link('Themes')
    select(name, from: 'Home Page Theme')
    find('body').click
    within('#themes') { click_on('Save') }
    expect(page).to have_content('The appearance was successfully updated')
  end

  context "as a repository admin" do
    it 'sets the cultural repository theme when the theme form is saved' do
      login_as admin
      save_home_theme('Cultural Repository')

      click_link('Themes')
      expect(page).to have_select('Home Page Theme', selected: 'Cultural Repository')

      visit '/'
      expect(page).to have_css('body.cultural_repository')
    end
  end

  context 'when the cultural repository theme is selected' do
    it 'renders the partials in the theme folder' do # rubocop:disable RSpec/ExampleLength
      login_as admin
      save_home_theme('Cultural Repository')

      visit '/'
      expect(page).to have_css('body.cultural_repository')
      expect(page).to have_css('nav.navbar.cultural-repository-nav')
      expect(page).to have_css('div.cultural-repository.facets')
      expect(page).to have_css('div.cultural-repository.featured-works-container')
      expect(page).to have_css('div.cultural-repository.recent-works-container')
      expect(page).to have_css('div.cultural-repository.collections-container')
      expect(page).not_to have_css('ul#homeTabs')
      expect(page).not_to have_css('ul.nav.nav-pills')
      expect(page).not_to have_css('div.home_share_work')
      expect(page).not_to have_css('nav.navbar.navbar-default.navbar-static-top')
      expect(page).not_to have_css('background-container-gradient')
    end
  end
end
