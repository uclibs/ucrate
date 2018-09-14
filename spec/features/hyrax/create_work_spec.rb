# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating a new Work', :js, :workflow do
  let(:user) { create(:user) }
  let!(:ability) { ::Ability.new(user) }
  let(:file1) { File.open(fixture_path + '/world.png') }
  let(:file2) { File.open(fixture_path + '/image.jp2') }
  let!(:uploaded_file1) { Hyrax::UploadedFile.create(file: file1, user: user) }
  let!(:uploaded_file2) { Hyrax::UploadedFile.create(file: file2, user: user) }

  before do
    # Grant the user access to deposit into an admin set.
    create(:permission_template_access,
           :deposit,
           permission_template: create(:permission_template, with_admin_set: true, with_active_workflow: true),
           agent_type: 'user',
           agent_id: user.user_key)
    # stub out characterization. Travis doesn't have fits installed, and it's not relevant to the test.
    allow(CharacterizeJob).to receive(:perform_later)
  end

  context "when the user is not a proxy" do
    before do
      sign_in user
      visit '/dashboard'

      within('.sidebar') do
        click_link 'Works'
      end
      click_link "Add new work"
      expect(page).to have_link('Add New', href: '/concern/generic_works/new?locale=en')
      click_link('Add New', href: '/concern/generic_works/new?locale=en')
    end

    it 'defaults to public visibility' do
      expect(page).to have_checked_field('generic_work_visibility_open')
    end

    it 'creates the work' do
      sleep 5
      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"
      within('span#addfiles') do
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/image.jp2", visible: false)
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/jp2_fits.xml", visible: false)
      end
      click_link "Relationships"
      expect(page).to have_css("div.generic_work_admin_set_id", visible: false)
      click_link "Metadata" # switch tab

      title_element = find_by_id("generic_work_title")
      title_element.set("My Test Work  ") # Add whitespace to test it getting removed

      college_element = find_by_id("generic_work_college")
      college_element.select("Business")

      select 'In Copyright', from: "generic_work_rights_statement"
      expect(page).to have_content("License Wizard")
      select 'Attribution-ShareAlike 4.0 International', from: 'generic_work_license'

      expect(page).to have_field("Creator", with: user.name_for_works)
      fill_in('Creator', with: 'Doe, Jane')

      fill_in('Program or Department', with: 'University Department')
      fill_in('Description', with: 'This is a description.')

      choose('generic_work_visibility_open')
      expect(page).not_to have_content('Please note, making something visible to the world (i.e. marking this as Open Access) may be viewed as publishing which could impact your ability to')
      check('agreement')
      # These lines are for debugging, should this test fail
      # puts "Required metadata: #{page.evaluate_script(%{$('#form-progress').data('save_work_control').requiredFields.areComplete})}"
      # puts "Required files: #{page.evaluate_script(%{$('#form-progress').data('save_work_control').uploads.hasFiles})}"
      # puts "Agreement : #{page.evaluate_script(%{$('#form-progress').data('save_work_control').depositAgreement.isAccepted})}"
      click_on('Save')
      expect(page).to have_content('My Test Work')
      expect(page).to have_content "Your files are being processed by Scholar@UC in the background."
    end
  end

  context 'when the user is a proxy' do
    let(:second_user) { create(:user) }

    before do
      ProxyDepositRights.create!(grantor: second_user, grantee: user)
      sign_in user
      visit '/dashboard'

      within('.sidebar') do
        click_link 'Works'
      end

      click_link "Add new work"
      # Needed if there are multiple work types
      expect(page).to have_link('Add New', href: '/concern/generic_works/new?locale=en')
      click_link('Add New', href: '/concern/generic_works/new?locale=en')
    end

    it "allows on-behalf-of deposit" do
      page.save_screenshot('virus.png')
      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      within('span#addfiles') do
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/image.jp2", visible: false)
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/jp2_fits.xml", visible: false)
      end
      click_link "Metadata" # switch tab
      expect(page).to have_field("Creator", with: second_user.name_for_works)

      title_element = find_by_id("generic_work_title")
      title_element.set("My Test Work  ") # Add whitespace to test it getting removed

      select 'In Copyright', from: "generic_work_rights_statement"
      select 'Attribution-ShareAlike 4.0 International', from: 'generic_work_license'

      expect(page).to have_field("Creator", with: user.name_for_works)
      fill_in('Creator', with: 'Doe, Jane')

      college_element = find_by_id("generic_work_college")
      college_element.select("Business")

      fill_in('Program or Department', with: 'University Department')
      fill_in('Description', with: 'This is a description.')

      choose('generic_work_visibility_open')
      expect(page).not_to have_content('Please note, making something visible to the world (i.e. marking this as Open Access) may be viewed as publishing which could impact your ability to')
      select(second_user.user_key, from: 'On behalf of')
      sleep 1
      check('agreement')
      # These lines are for debugging, should this test fail
      # puts "Required metadata: #{page.evaluate_script(%{$('#form-progress').data('save_work_control').requiredFields.areComplete})}"
      # puts "Required files: #{page.evaluate_script(%{$('#form-progress').data('save_work_control').uploads.hasFiles})}"
      # puts "Agreement : #{page.evaluate_script(%{$('#form-progress').data('save_work_control').depositAgreement.isAccepted})}"
      click_on('Save')
      expect(page).to have_content('My Test Work')
      expect(page).to have_content "Your files are being processed by Scholar@UC in the background."
      expect(page).to have_content("Permanent link to this page")

      click_on('image.jp2')
      expect(page).to have_content("Permanent link to this page")

      sign_in second_user
      visit '/dashboard'
      within('.sidebar') do
        click_link 'Works'
      end
      expect(page).to have_content "My Test Work"
    end
  end
end
