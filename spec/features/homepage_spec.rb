# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "The homepage" do
  let(:work1) { create(:work, :public, title: ['Work 1']) }

  before do
    create(:featured_work, work_id: work1.id)
  end

  it 'shows featured works' do
    visit root_path
    expect(page).to have_link "Work 1"
  end

  it 'renders the featured researcher partial' do
    visit root_path
    expect(page).to have_content 'FEATURED RESEARCHER'
  end

  it 'renders the featured collection partial' do
    visit root_path
    expect(page).to have_content 'FEATURED COLLECTION'
  end

  it 'renders the featured work partial' do
    visit root_path
    expect(page).to have_content 'FEATURED WORK'
  end

  it 'shows introduction text' do
    visit root_path
    expect(page).to have_css('div.scholar-home-tag.text-center')
  end

  it 'shows external links' do
    visit root_path
    expect(page).to have_css('div.ext-links.text-center')
  end

  it 'shows partners' do
    visit root_path
    expect(page).to have_css('div.partner-branding.row')
  end

  context "as an admin" do
    let(:user) { create(:admin) }

    before do
      sign_in user
    end

    it 'shows featured works that I can sort' do
      visit root_path
      within '.dd-item' do
        expect(page).to have_link "Work 1"
      end
    end
  end
end
