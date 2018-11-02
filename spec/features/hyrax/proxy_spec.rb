# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'proxy', type: :feature do
  let(:user) { create(:user) }
  let(:second_user) { create(:user, display_name: 'Second User') }

  describe 'add proxy in dashboard', :js do
    it "creates a proxy" do
      sign_in user
      visit "/dashboard"
      click_link "Your activity"
      within 'div#proxy_management' do
        click_link "Manage Proxies"
      end
      expect(first("td.depositor-name")).to be_nil

      # BEGIN create_proxy_using_partial
      find('a.select2-choice').click
      find(".select2-input").set(second_user.user_key)
      expect(page).to have_css("div.select2-result-label")
      find("div.select2-result-label").click
      # END create_proxy_using_partial

      expect(page).to have_css('td.depositor-name', text: second_user.name)
      expect(page).to have_link('Delete Proxy')
    end
  end

  describe 'as proxy', js: true, clean_repo: true do
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    before do
      # Create a single action that can be taken
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

      # Grant the user access to deposit into the admin set.
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'second_user',
        agent_id: second_user.user_key,
        access: 'deposit'
      )

      sign_in user
      visit '/dashboard'
      within 'div#proxy_management' do
        click_link "Manage Proxies"
      end
      sleep(5)
      find('a.select2-choice').click
      find(".select2-input").set(second_user.user_key)
      expect(page).to have_css("div.select2-result-label")
      find("div.select2-result-label").click
      sleep(5)
      logout
    end

    it "is able to create, edit, and delete work on behalf of" do
      sign_in second_user
      visit '/dashboard'
      within('.sidebar') do
        click_link "Works"
      end
      click_link "Add new work"
      expect(page).to have_link('Add New', href: '/concern/generic_works/new?locale=en')
      click_link('Add New', href: '/concern/generic_works/new?locale=en')
      sleep(5)
      title_element = find_by_id("generic_work_title")
      title_element.set("My proxy submitted work")
      fill_in('Creator', with: 'Grantor')
      fill_in('Description', with: 'A proxy deposited work')
      select 'All rights reserved', from: "generic_work_license"
      select(user.user_key, from: 'On behalf of')
      check('agreement')
      click_on('Save')

      # Edit
      expect(page).to have_link 'Edit'
      click_link 'Edit'
      expect(current_path).to include('edit')
      fill_in('Creator', with: 'Edited grantor')
      fill_in('Description', with: 'An edited proxy deposited work')
      check('agreement')
      page.find('#savewidget').click
      page.find('#with_files_submit').click
      sleep(10)
      expect(current_path).to include('/concern/generic_works/')
      expect(page).to have_content('Edited grantor')

      # Delete
      expect(page).to have_link 'Delete'
      click_link 'Delete'
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content 'Deleted'
    end

    it "removes a proxy" do
      sign_in user
      visit '/dashboard'
      within 'div#proxy_management' do
        click_link "Manage Proxies"
      end
      sleep(5)
      click_link 'Delete Proxy'
      expect(page).not_to have_content(second_user.display_name)
      logout
      sign_in second_user
      visit '/dashboard'
      within('.sidebar') do
        click_link "Works"
      end
      #      click_link 'Managed Works'
      expect(page).not_to have_content "My proxy submitted work"
    end
  end
end
