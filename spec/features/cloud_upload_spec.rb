# frozen_string_literal: true

require 'rails_helper'

describe "Selecting files to import from cloud providers", js: true, type: :feature do
  let(:user) { create(:user) }

  before do
    # Grant the user access to deposit into an admin set.
    create(:permission_template_access,
           :deposit,
           permission_template: create(:permission_template, with_admin_set: true, with_active_workflow: true),
           agent_type: 'user',
           agent_id: user.user_key)

    sign_in user
    visit '/dashboard'
    click_link 'Works'
    click_link "Add new work"
    choose "payload_concern", option: "GenericWork"
    click_button 'Create work'
  end

  it "has a Cloud file picker using browse-everything" do
    click_link "Files"
    expect(page).to have_content "Add cloud files"
  end
end
