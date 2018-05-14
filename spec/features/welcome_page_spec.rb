require 'rails_helper'

describe 'sign in when user has waived welcome page, type', :feature do
  let(:user) { FactoryBot.create(:user, waived_welcome_page: true) }
  let(:password) { FactoryBot.attributes_for(:user).fetch(:password) }

  it 'when user has waived welcome page' do
    visit user_session_path
    fill_in('user[email]', with: user.email)
    fill_in('user[password]', with: user.password)
    click_on('Log in')
    expect(page).to have_current_path(Hyrax::Engine.routes.url_helpers.root_path)
  end
end
