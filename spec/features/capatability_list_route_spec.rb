# frozen_string_literal: true

require 'rails_helper'

describe 'redirects user to sanitize error page, type', :feature do
  it 'when visiting capability_list_path' do
    visit capability_list_path
    expect(page).to have_content('Page Not Found')
  end
end
