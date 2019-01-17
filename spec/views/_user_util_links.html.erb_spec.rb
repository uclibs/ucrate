# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/_user_util_links.html.erb', type: :view do
  let(:join_date) { 5.days.ago }
  let(:can_create_file) { true }
  let(:can_create_collection) { true }

  before do
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(stub_model(User, user_key: 'userX'))
    allow(view).to receive(:can?).with(:create, GenericWork).and_return(can_create_file)
    allow(view).to receive(:can?).with(:create_any, Collection).and_return(can_create_collection)
    view.stub_chain(:current_ability, :can_create_any_work?).and_return(true) # rubocop:disable RSpec/MessageChain
    view.stub_chain(:create_work_presenter, :many?).and_return(true) # rubocop:disable RSpec/MessageChain
  end

  it 'has dropdown list of links' do
    render
    page = Capybara::Node::Simple.new(rendered)
    expect(page).to have_link 'userX', href: hyrax.dashboard_profile_path('userX')
    expect(rendered).to have_link 'Dashboard', href: hyrax.dashboard_path
    expect(rendered).to have_link 'View Profile', href: hyrax.dashboard_profile_path('userX')
    expect(rendered).to have_link 'Edit Profile', href: hyrax.edit_dashboard_profile_path('userX')
    expect(rendered).to have_link "What's New", href: main_app.whats_new_path
  end

  context 'when the user is using shibboleth' do
    before do
      allow(view).to receive(:current_user).and_return(stub_model(User, user_key: 'userX', provider: 'shibboleth'))
      render
    end

    it 'does not show the change password manu option' do
      expect(rendered).not_to have_link 'Change password'
    end
  end

  context 'when the user is not using shibboleth' do
    before do
      allow(view).to receive(:current_user).and_return(stub_model(User, user_key: 'userX', provider: nil))
      render
    end

    it 'shows the change password manu option' do
      expect(rendered).to have_link 'Change password', href: edit_user_registration_path
    end
  end

  it 'shows the number of outstanding messages' do
    render
    expect(rendered).to have_selector "a[aria-label='You have no unread notifications'][href='#{hyrax.notifications_path}']"
    expect(rendered).to have_selector 'a.notify-number span.label-default.invisible', text: '0'
  end

  describe 'translations' do
    context 'with two languages' do
      before do
        allow(view).to receive(:available_translations).and_return('en' => 'English', 'es' => 'Español')
        render
      end
      it 'displays the current language' do
        expect(rendered).to have_link('English')
      end
    end
    context 'with one language' do
      before do
        allow(view).to receive(:available_translations).and_return('en' => 'English')
        render
      end
      it 'does not display the language picker' do
        expect(rendered).not_to have_link('English')
      end
    end
  end
end
