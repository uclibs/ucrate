# frozen_string_literal: true
require 'rails_helper'

describe 'locales', :clean_repo do
  before do
    Rails.application.config.application_root_url = 'http://localhost:3000'
  end

  describe 'work show page' do
    let(:work_type) { "generic_work" }
    let!(:user) { create(:user) }
    let!(:work) { create(:generic_work_with_one_file, title: ["Magnificent splendor"], description: ["My description"], source: ["The Internet"], based_near: ["USA"], user: user) }
    let(:work_path) { "/concern/#{work_type}s/#{work.id}" }
    let(:file_path) { "/concern/parent/#{work.id}/file_sets/#{work.file_sets.first.id}?locale=en" }

    before do
      sign_in user
      visit work_path
    end

    it "has a fileset link with the correct locale" do
      expect(page).to have_link(work.file_sets.first.title.first, href: file_path)
    end
  end

  describe 'masthead' do
    before do
      visit search_catalog_path
    end

    it "has a link with the correct locale" do
      expect(page).to have_link('|', href: '/?locale=en')
    end
  end
end
