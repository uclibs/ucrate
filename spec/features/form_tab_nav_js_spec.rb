# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Navigating between tabs in create work form', :js, :workflow do
  let(:user) { create(:user) }
  let!(:ability) { ::Ability.new(user) }

  before do
    # Grant the user access to deposit into an admin set.
    create(:permission_template_access,
           :deposit,
           permission_template: create(:permission_template, with_admin_set: true, with_active_workflow: true),
           agent_type: 'user',
           agent_id: user.user_key)
    # stub out characterization. Travis doesn't have fits installed, and it's not relevant to the test.
    allow(CharacterizeJob).to receive(:perform_later)

    sign_in user
    visit '/dashboard'

    within('.sidebar') do
      click_link 'Works'
    end
    click_link "Add new work"
    expect(page).to have_link('Add New', href: '/concern/generic_works/new?locale=en')
    click_link('Add New', href: '/concern/generic_works/new?locale=en')
  end

  it 'matches active tab to form content' do
    click_link "Attaching a file"
    expect(page).to have_content('You can add one or more files ')
    expect(page).to have_selector("ul li.active a", 'Files')
  end
end
