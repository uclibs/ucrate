# frozen_string_literal: true

require 'rails_helper'

describe "Bulkrax links", type: :feature do
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
end
