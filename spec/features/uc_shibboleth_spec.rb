  # frozen_string_literal: true

  require 'rails_helper'

  describe 'UC account workflow', type: :feature do
    let(:user) { FactoryBot.create(:user) }
    let(:password) { FactoryBot.attributes_for(:user).fetch(:password) }
    let(:locale) { 'en' }

    describe 'overridden devise password reset page' do
      context 'with a uc.edu email address' do
        email_address = 'fake.user@uc.edu'
        it 'rejects password reset for @.uc.edu user' do
          visit new_user_password_path
          fill_in('user[email]', with: email_address)
          click_on('Send me reset password instructions')
          expect(page).to have_content('You cannot reset passwords for @uc.edu accounts. Use your UC Central Login instead')
        end
      end

      context 'with a non uc.edu email address' do
        it 'allows a password reset' do
          visit new_user_password_path
          fill_in('user[email]', with: user.email)
          click_on('Send me reset password instructions')
          expect(page).to have_content('You will receive an email with instructions on how to reset your password in a few minutes.')
        end
      end

      context 'with an invalid email address' do
        email_address = 'fake.user@mail.edu'
        it 'allows a password reset' do
          visit new_user_password_path
          fill_in('user[email]', with: email_address)
          click_on('Send me reset password instructions')
          expect(page).to have_content('Email not found')
        end
      end
    end

    describe 'overridden devise password reset page' do
      it 'shows a Central Login option with shibboleth enabled' do
        AUTH_CONFIG['shibboleth_enabled'] = true
        visit new_user_password_path
        expect(page).to have_content('Central Login form')
      end

      it 'does not show a Central Login option with shibboleth disabled' do
        AUTH_CONFIG['shibboleth_enabled'] = false
        visit new_user_password_path
        skip "this string displays without regard to shibboleth status"
        expect(page).not_to have_content('Central Login form') # This string appears in the help text on the page
      end

      it 'does not display the Shared links at the bottom' do
        visit new_user_password_path
        expect(page).not_to have_link('Sign in', href: '/users/sign_in')
        expect(page).not_to have_link('Sign up', href: '/users/sign_up')
      end
    end

    describe 'overridden devise registration page' do
      it 'shows a sign up form if signups are enabled' do
        AUTH_CONFIG['signups_enabled'] = true
        visit new_user_registration_path
        expect(page).to have_field('user[email]')
      end

      it 'shows a request link of signups are disabled' do
        AUTH_CONFIG['signups_enabled'] = false
        visit new_user_registration_path
        expect(page).to have_link('use the contact page', href: contact_path(locale: locale))
      end
    end

    describe 'overridden devise sign-in page' do
      it 'shows a shibboleth login link if shibboleth is enabled' do
        AUTH_CONFIG['shibboleth_enabled'] = true
        visit new_user_session_path
        expect(page).to have_link('Central Login form', href: user_shibboleth_omniauth_authorize_path(locale: locale))
      end

      it 'does not show a shibboleth login link if shibboleth is disabled' do
        AUTH_CONFIG['shibboleth_enabled'] = false
        visit new_user_session_path
        expect(page).not_to have_link('Central Login form', href: user_shibboleth_omniauth_authorize_path(locale: locale))
      end

      it 'shows a signup link if signups are enabled' do
        AUTH_CONFIG['signups_enabled'] = true
        visit new_user_session_path
        expect(page).to have_link('Sign up', href: new_user_registration_path(locale: locale))
      end

      it 'does not show signup link if signups are disabled' do
        AUTH_CONFIG['signups_enabled'] = false
        visit new_user_session_path
        expect(page).not_to have_link('Sign up', href: new_user_registration_path(locale: locale))
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
          expect(page).to have_field('user[email]')
        end
      end
    end

    describe 'shibboleth password management' do
      it 'hides the password change fields for shibboleth users' do
        login_as(user)
        user.provider = 'shibboleth'
        visit hyrax.edit_dashboard_profile_path(user)
        expect(page).not_to have_field('user[password]')
        expect(page).not_to have_field('user[password_confirmation]')
      end
    end

    describe 'home page login button' do
      it 'shows the correct login link' do
        visit root_path
        expect(page).to have_link('Login', href: login_path + '?locale=en')
      end
    end

    describe 'a user using a UC Shibboleth login' do
      it "redirects to the UC Shibboleth logout page after logout" do
        create_cookie('login_type', 'shibboleth')
        visit('/users/sign_out')
        expect(page).to have_content("You have been logged out of the University of Cincinnati's Login Service")
      end
    end

    describe 'a user using a local login' do
      it "redirects to the home page after logout" do
        create_cookie('login_type', 'local')
        visit('/users/sign_out')
        expect(page).to have_title("Scholar@UC")
      end
    end
  end
