# frozen_string_literal: true

require 'rails_helper'

describe "Bulkrax links", type: :feature do
  context "when admin user is logged in" do
    let(:user) { create(:admin) }

    before do
      admin = Role.find_or_create_by(name: "admin")
      admin.users << user
      admin.save
    end

    it "for importer display" do
      sign_in user
      visit '/importers'
      expect(page).to have_link('New')
    end

    it "for exporter display" do
      sign_in user
      visit '/exporters'
      expect(page).to have_link('New')
    end

    it "for importer dashboard display" do
      sign_in user
      visit '/dashboard'
      expect(page).to have_link('Importers')
    end

    it "for exporter dashboard display" do
      sign_in user
      visit '/dashboard'
      expect(page).to have_link('Exporters')
    end
  end

  context "when non-admin users is logged in", type: :feature do
    let(:user) { create(:user) }

    it "for importer display" do
      sign_in user
      visit '/importers'
      expect(page).not_to have_link('New')
    end

    it "for exporter display" do
      sign_in user
      visit '/exporters'
      expect(page).not_to have_link('New')
    end

    it "for importer dashboard display" do
      sign_in user
      visit '/dashboard'
      expect(page).not_to have_link('Importers')
    end

    it "for exporter dashboard display" do
      sign_in user
      visit '/dashboard'
      expect(page).not_to have_link('Exporters')
    end
  end
end
