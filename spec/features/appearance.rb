# frozen_string_literal: true

require 'rails_helper'

describe "Default UI colors", type: :feature do
  let(:user) { create(:admin) }

  before do
    admin = Role.find_or_create_by(name: "admin")
    admin.users << user
    admin.save
    require_relative '../../config/initializers/appearance.rb'
  end

  it "are set" do # rubocop:disable RSpec/ExampleLength
    sign_in user
    visit hyrax.admin_appearance_path
    expect(page).to have_field(id: 'admin_appearance_header_background_color', with: '#222')
    expect(page).to have_field(id: 'admin_appearance_header_text_color', with: '#ffffff')
    expect(page).to have_field(id: 'admin_appearance_link_color', with: '#e00122')
    expect(page).to have_field(id: 'admin_appearance_footer_link_color', with: '#ffffff')
    expect(page).to have_field(id: 'admin_appearance_primary_button_background_color', with: '#e00122')
  end
end
