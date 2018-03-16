# frozen_string_literal: true

require 'rails_helper'

describe 'UC account workflow', type: :feature do
  let(:user) { FactoryBot.create(:user) }
  let(:password) { FactoryBot.attributes_for(:user).fetch(:password) }

  filepath = "config/authentication.yml"
  yaml = YAML.load_file(filepath)

  describe 'overridden devise password reset page' do
    context 'with a uc.edu email address' do
      email_address = 'fake.user@uc.edu'
      it 'rejects password reset for @.uc.edu user' do
        visit new_user_password_path
        fill_in('user[email]', with: email_address)
        click_on('Send me reset password instructions')
        page.should have_content('You cannot reset passwords for @uc.edu accounts. Use your UC Central Login instead')
      end
    end

    context 'with a non uc.edu email address' do
      it 'allows a password reset' do
        visit new_user_password_path
        fill_in('user[email]', with: user.email)
        click_on('Send me reset password instructions')
        page.should have_content('You will receive an email with instructions on how to reset your password in a few minutes.')
      end
    end
  end

  describe 'overridden devise password reset page' do
    it 'shows a Central Login option' do
      visit new_user_password_path
      if yaml['test']['shibboleth_enabled'] == true
        page.should have_content('Central Login form')
      else
        page.should_not have_content('Central Login form')
      end
    end

    it 'does not display the Shared links at the bottom' do
      visit new_user_password_path
      expect(page).not_to have_link('Sign in', href: '/users/sign_in')
      expect(page).not_to have_link('Sign up', href: '/users/sign_up')
    end
  end

  describe 'overridden devise registration page' do
    it 'shows a sign up form if signups are enabled or a request link if signups are disabled' do
      visit new_user_registration_path
      if yaml['test']['signups_enabled'] == true
        page.should have_field('user[email]')
      else
        expect(page).to have_link('use the contact page', href: '/contact')
      end
    end
  end

  describe 'overridden devise sign-in page' do
    it 'shows a shibboleth login link if shibboleth is enabled' do
      visit new_user_session_path
      if yaml['test']['shibboleth_enabled'] == true
        expect(page).to have_link('Central Login form', href: '/users/auth/shibboleth')
      else
        expect(page).not_to have_link('Central Login form', href: '/users/auth/shibboleth')
      end
    end

    it 'shows a signup link if signups are enabled' do
      visit new_user_session_path
      if yaml['test']['signups_enabled'] == true
        page.should have_link('Sign up', href: new_user_registration_path)
      else
        page.should_not have_link('Sign up', href: new_user_registration_path)
      end
    end
  end

  describe 'shibboleth login page' do
    context 'when shibboleth is enabled' do
      before do
        AUTH_CONFIG['shibboleth_enabled'] = true
        visit login_path
      end

      it 'shows a shibboleth login link and local login link' do
        expect(page).to have_link('UC Central Login username', href: 'https://www.uc.edu/distance/Student_Orientation/One_Stop_Student_Resources/central-log-in-.html')
        expect(page).to have_link('log in using a local account', href: new_user_session_path + '?locale=en')
      end
    end

    context 'when shibboleth is not enabled' do
      before do
        AUTH_CONFIG['shibboleth_enabled'] = false
        visit login_path
      end

      it 'shows the local log in page' do
        page.should have_field('user[email]')
      end
    end
  end

  describe 'shibboleth password management' do
    it 'hides the password change fields for shibboleth users' do
      login_as(user)
      user.provider = 'shibboleth'
      visit hyrax.edit_dashboard_profile_path(user)
      page.should_not have_field("user[password]")
      page.should_not have_field("user[password_confirmation]")
    end
  end

  describe 'home page login button' do
    it 'shows the correct login link for users' do
      visit root_path
      if yaml['test']['shibboleth_enabled'] == true
        expect(page).to have_link('Login', href: login_path + '?locale=en')
      else
        expect(page).to have_link('Login', href: new_user_session_path + '?locale=en')
      end
    end
  end

  describe 'a user using a UC Shibboleth login' do
    it "redirects to the UC Shibboleth logout page after logout" do
      create_cookie('login_type', 'shibboleth')
      visit('/users/sign_out')
      page.should have_content("You have been logged out of the University of Cincinnati's Login Service")
    end
  end

  describe 'a user using a local login' do
    it "redirects to the home page after logout" do
      create_cookie('login_type', 'local')
      visit('/users/sign_out')
      page.should have_title("UCrate")
    end
  end
end
