# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Document`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.describe 'Create a Document', :feature, js: true do
  context 'a logged in user', :clean_repo do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    # Form values
    let(:title) { 'My Test Work' }
    let(:college) { 'Business' }
    let(:creator) { 'Doe, Jane' }
    let(:description) { 'Description' }
    let(:program) { 'My University Department' }
    let(:license) { 'Attribution-ShareAlike 4.0 International' }
    let(:publisher) { 'Spy Magazine' }
    let(:date_created) { '1969' }
    let(:alternate_title) { 'Or, your test work' }
    let(:genre) { 'Book' }
    let(:subject_term) { 'Isnt everything about death in one way or another' }
    let(:geographic_subject) { 'Cincinnati' }
    let(:time_period) { 'Year of the whopper' }
    let(:language) { 'American English' }
    let(:required_software) { 'Corel draw' }
    let(:note) { 'This is a note' }
    let(:external_link) { 'http://www.chitterchat.com' }

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
      expect(page).to have_link('Add New', href: '/concern/documents/new?locale=en')
      click_link('Add New', href: '/concern/documents/new?locale=en')

      sleep 5

      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"
      within('span#addfiles') do
        attach_file("files[]", "#{fixture_path}/image.jp2", visible: false)
        attach_file("files[]", "#{fixture_path}/png_fits.xml", visible: false)
      end
      click_link "Metadata" # switch tab

      # Required fields

      title_element = find_by_id("document_title")
      title_element.set(title) # Add whitespace to test it getting removed

      college_element = find_by_id("document_college")
      college_element.select(college)

      expect(page).to have_content("License Wizard")
      expect(page).not_to have_content('Rights statement')
      select license, from: 'document_license'

      fill_in('Creator', with: creator)
      fill_in('Description', with: description)
      fill_in('Program or Department', with: program)

      # Non-required fields

      fill_in('Publisher (Required for DOI registration)', with: publisher)
      fill_in('Date Created', with: date_created)
      fill_in('document_alternate_title', with: alternate_title)
      select(genre, from: 'document_genre')
      fill_in('Subject', with: subject_term)
      fill_in('Geographic Subject', with: geographic_subject)
      fill_in('Time Period', with: time_period)
      fill_in('Language', with: language)
      fill_in('Required Software', with: required_software)
      fill_in('Note', with: note)
      fill_in('External Link', with: external_link)

      choose('document_visibility_open')
      expect(page).not_to have_content('Please note, making something visible to the world (i.e. marking this as Open Access) may be viewed as publishing which could impact your ability to')
      check('agreement')

      click_on('Save')
      expect(page).to have_content(title)
      expect(page).to have_content "Your files are being processed by Scholar@UC in the background."
      expect(page).to have_content("Permanent link to this page")

      # Edit the work to verify form values persist
      click_on('Edit')

      expect(page).to have_field('document_title', with: title)
      expect(page).to have_field('document_creator', with: creator)
      expect(page).to have_field('document_college', with: college)
      expect(page).to have_field('Program or Department', with: program)
      expect(page).to have_field('Description', with: description)
      expect(page).to have_select('document_license', selected: license)
      expect(page).to have_field('Publisher (Required for DOI registration)', with: publisher)
      expect(page).to have_field('Date Created', with: date_created)
      expect(page).to have_field('document_alternate_title', with: alternate_title)
      expect(page).to have_select('document_genre', with_selected: genre)
      expect(page).to have_field('Subject', with: subject_term)
      expect(page).to have_field('Geographic Subject', with: geographic_subject)
      expect(page).to have_field('Time Period', with: time_period)
      expect(page).to have_field('Language', with: language)
      expect(page).to have_field('Required Software', with: required_software)
      expect(page).to have_field('Note', with: note)
      expect(page).to have_field('External Link', with: external_link)

      check('agreement')
      click_on('Save')

      click_on('image.jp2')
      expect(page).to have_content("Permanent link to this page")
    end
  end
end
