require 'rails_helper'

describe 'application/index' do

  context 'when user is not logged in' do
    it 'displays a log in link' do
      render
      expect(rendered).to have_link('Log in', new_user_session_path)
    end
  end

  context 'when user is logged in' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
    end

    it 'displays who is logged in' do
      render
      expect(rendered).to have_text('Logged in as fake.user@uc.edu')
    end

    it 'displays a log out link' do
      render
      expect(rendered).to have_link('Log out', destroy_user_session_path)
    end
  end

end

