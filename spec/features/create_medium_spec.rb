# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Medium`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.describe 'Create a Medium', js: true do
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    before do
      # Create a single action that can be taken
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

      # Grant the user access to deposit into the admin set.
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'user',
        agent_id: user.user_key,
        access: 'deposit'
      )
      login_as user
      allow(CharacterizeJob).to receive(:perform_later)
    end

    it do
      visit '/dashboard'
      within('.sidebar') do
        click_link "Works"
      end
      click_link "Add new work"

      # If you generate more than one work uncomment these lines
      expect(page).to have_link('Add New', href: '/concern/media/new?locale=en')
      click_link('Add New', href: '/concern/media/new?locale=en')

      sleep 5

      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"
      within('span#addfiles') do
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/image.jp2", visible: false)
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/jp2_fits.xml", visible: false)
      end
      click_link "Metadata" # switch tab

      title_element = find_by_id("medium_title")
      title_element.set("My Test Work  ") # Add whitespace to test it getting removed

      college_element = find_by_id("medium_college")
      college_element.select("Business")

      expect(page).to have_content("License Wizard")
      expect(page).not_to have_content('Rights statement')
      select 'Attribution-ShareAlike 4.0 International', from: 'medium_license'

      fill_in('Creator', with: 'Doe, Jane')
      fill_in('Description', with: 'Description')
      fill_in('Program or Department', with: 'University Department')

      choose('medium_visibility_open')
      expect(page).not_to have_content('Please note, making something visible to the world (i.e. marking this as Open Access) may be viewed as publishing which could impact your ability to')
      check('agreement')

      click_on('Save')
      expect(page).to have_content('My Test Work')
      expect(page).to have_content "Your files are being processed by Scholar@UC in the background."
      expect(page).to have_content("Permanent link to this page")

      click_on('image.jp2')
      expect(page).to have_content("Permanent link to this page")
    end
  end
end
