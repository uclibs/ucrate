# frozen_string_literal: true

require 'rails_helper'

describe WelcomeMailer do
  let(:user_email) { 'example@test.com' }
  let(:user_password) { 'really_good_password' }
  let(:email) { ActionMailer::Base.deliveries.last }

  before do
    AUTH_CONFIG['signups_enabled'] = true
    visit new_user_registration_path
    fill_in 'user_email', with: user_email
    fill_in 'user_password', with: user_password
    fill_in 'user_password_confirmation', with: user_password

    click_button 'Sign up'
  end
  after do
    ActionMailer::Base.deliveries = []
    User.find_by_email(user_email).delete
  end
  it 'sends welcome email to user upon registration' do
    email.to.should eq([user_email])
    email.from.should == ["scholar@uc.edu"]
  end
  context 'when user is a student' do
    let(:student_user) { FactoryBot.create(:user, uc_affiliation: 'student') }
    let(:student_email) { described_class.welcome_email(student_user) }

    it 'sends a student specific welcome email' do
      student_email.subject.should == "Welcome to Ucrate@UC, UC students!"
    end
  end
  context 'when user is NOT a student' do
    let(:faculty_user) { FactoryBot.create(:user, uc_affiliation: 'AnythingElse') }
    let(:faculty_email) { described_class.welcome_email(faculty_user) }

    it 'sends the default welcome email to non-student users' do
      faculty_email.subject.should == "Welcome to Ucrate@UC!"
    end
  end
end
