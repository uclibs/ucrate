# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work StudentWork`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.describe 'Create a StudentWork', :feature, js: true do
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
    let(:advisor) { 'Neil Armstrong' }
    let(:committee_member) { 'John Glenn' }
    let(:degree) { 'M.S.' }
    let(:date_created) { '2018' }
    let(:type) { 'Painting' }
    let(:program) { 'My University Department' }
    let(:license) { 'Attribution-ShareAlike 4.0 International' }
    let(:publisher) { 'Spy Magazine' }
    let(:alternate_title) { 'Or, your test work' }
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
      expect(page).to have_link('Add New', href: '/concern/student_works/new?locale=en')

      click_link('Add New', href: '/concern/student_works/new?locale=en')

      sleep 5

      click_link "Files" # switch tab

      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"
      within('span#addfiles') do
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/image.jp2", visible: false)
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/jp2_fits.xml", visible: false)
      end
      click_link "Metadata" # switch tab

      # Required fields

      title_element = find_by_id("student_work_title")
      title_element.set(title)

      expect(page).to have_content("License Wizard")
      expect(page).not_to have_content('Rights statement')
      select license, from: 'student_work_license'

      college_element = find_by_id("student_work_college")
      college_element.select(college)

      fill_in('student_work_title', with: title)
      fill_in('Creator', with: creator)
      fill_in('Description', with: description)
      fill_in('Advisor', with: advisor)
      fill_in('Program or Department', with: program)
      fill_in('Degree', with: degree)

      # Non-required fields

      fill_in('Degree', with: degree)
      fill_in('Date Created', with: date_created)
      fill_in('Publisher (Required for DOI registration)', with: publisher)
      fill_in('student_work_alternate_title', with: alternate_title)
      select(type, from: 'student_work_genre')
      fill_in('Subject', with: subject_term)
      fill_in('Geographic Subject', with: geographic_subject)
      fill_in('Time Period', with: time_period)
      fill_in('Language', with: language)
      fill_in('student_work_required_software', with: required_software)
      fill_in('Note', with: note)
      fill_in('External Link', with: external_link)

      choose('student_work_visibility_open')
      expect(page).not_to have_content('Please note, making something visible to the world (i.e. marking this as Open Access) may be viewed as publishing which could impact your ability to')
      check('agreement')

      click_on('Save')
      expect(page).to have_content('My Test Work')
      expect(page).to have_content "Your files are being processed by Scholar@UC in the background."
      expect(page).to have_content("Permanent link to this page")

      # Edit the work to verify form values persist
      click_on('Edit')

      expect(page).to have_field('student_work_title', with: 'My Test Work')
      expect(page).to have_field('student_work_creator', with: creator)
      expect(page).to have_select('student_work_college', selected: college)
      expect(page).to have_field('Program or Department', with: program)
      expect(page).to have_field('Degree', with: degree)
      expect(page).to have_field('Date Created', with: date_created)
      expect(page).to have_field('Description', with: description)
      expect(page).to have_select('student_work_license', selected: license)
      expect(page).to have_field('Publisher (Required for DOI registration)', with: publisher)
      expect(page).to have_field('student_work_alternate_title', with: alternate_title)
      expect(page).to have_select('student_work_genre', selected: type)
      expect(page).to have_field('Subject', with: subject_term)
      expect(page).to have_field('Geographic Subject', with: geographic_subject)
      expect(page).to have_field('Time Period', with: time_period)
      expect(page).to have_field('Language', with: language)
      expect(page).to have_field('student_work_required_software', with: required_software)
      expect(page).to have_field('Note', with: note)
      expect(page).to have_field('External Link', with: external_link)

      check('agreement')
      click_on('Save')

      click_on('image.jp2')
      expect(page).to have_content("Permanent link to this page")
    end
  end
end
