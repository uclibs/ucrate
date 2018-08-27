# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "The static pages" do
  it do
    visit root_path
    click_link "About", match: :first
    click_link "Help", match: :first
  end
end
