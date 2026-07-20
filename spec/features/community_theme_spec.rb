# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin can select community theme', type: :feature, js: true, clean: true do
  let(:admin) { FactoryBot.create(:admin, email: 'admin@example.com', display_name: 'Julie Admin') }

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

  context 'as a repository admin' do
    it 'sets the community theme when the theme form is saved' do
      login_as admin
      save_home_theme('Community')

      click_link('Themes')
      expect(page).to have_select('Home Page Theme', selected: 'Community')

      visit '/'
      expect(page).to have_css('body.community')
    end

    it 'displays theme notes and wireframe in admin panel' do
      login_as admin
      visit '/admin/appearance'
      click_link('Themes')
      select('Community', from: 'Home Page Theme')
      find('body').click

      expect(page).to have_content('This theme is for demoing Hyku features')
      expect(page).to have_content('This theme uses a custom banner image')
      expect(page).to have_content('This theme uses home page text')
      expect(page).to have_content('This theme uses marketing text')
      expect(page.find('#home-wireframe img')['src']).to match(%r{/assets/themes/community/})
    end
  end

  context 'when the community theme is selected' do
    before do
      login_as admin
      save_home_theme('Community')
    end

    it 'renders the theme-specific layout' do
      visit '/'

      expect(page).to have_css('body.community')
      expect(page).to have_content('Featured Works')
      expect(page).to have_content('Collections')
      expect(page).not_to have_css('div.ir-stats')
      expect(page).not_to have_css('nav.cultural-repository-nav')
      expect(page).not_to have_css('div.institutional-repository-carousel')
    end

    it 'does not display featured researcher section' do
      ContentBlock.update_block(name: 'featured_researcher', value: '<h2>Test Researcher</h2>')

      visit '/'

      expect(page).not_to have_content('Test Researcher')
      expect(page).not_to have_css('.featured-researcher')
    end

    it 'displays featured works section' do
      visit '/'
      expect(page).to have_content('Featured Works')
    end

    it 'displays collections section' do
      visit '/'
      expect(page).to have_content('Collections')
    end

    it 'displays navigation links in the masthead' do
      page.driver.browser.manage.window.resize_to(1400, 1000)
      visit '/'

      expect(page).to have_css('#masthead.community-masthead')
      expect(page).to have_css('#masthead .navbar-nav')

      within('#masthead') do
        expect(page).to have_link('Home', visible: :all)
        expect(page).to have_link('About', visible: :all)
        expect(page).to have_link('Help', visible: :all)
        expect(page).to have_link('Contact', visible: :all)
      end
    end

    it 'displays search bar below the banner' do
      visit '/'

      expect(page).to have_css('.community-search-section')
      expect(page).to have_css('#search-form-header')
      expect(page).to have_field('q')
      expect(page).to have_button('Go')
    end
  end
end
