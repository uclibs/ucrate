# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Editing a work', type: :feature do
  let(:user) { create(:user) }
  let(:second_user) { create(:user) }
  let(:work) { build(:work, user: user, admin_set: another_admin_set) }
  let(:default_admin_set) do
    create(:admin_set, id: AdminSet::DEFAULT_ID,
                       title: ["Default Admin Set"],
                       description: ["A description"],
                       edit_users: [user.user_key])
  end
  let(:another_admin_set) do
    create(:admin_set, title: ["Another Admin Set"],
                       description: ["A description"],
                       edit_users: [user.user_key])
  end

  before do
    sign_in user
    work.ordered_members << create(:file_set, user: user, title: ['ABC123xyz'])
    work.read_groups = []
    work.save!
  end

  context 'when the user changes permissions' do
    let(:work) { create(:private_work, user: user, admin_set: default_admin_set) }

    it 'confirms copying permissions to files using Hyrax layout and shows updated value', with_nested_reindexing: true do
      # e.g. /concern/generic_works/jq085k20z/edit
      visit edit_hyrax_generic_work_path(work)
      choose('generic_work_visibility_open')
      check('agreement')
      click_on('Save')
      expect(page).to have_content 'Apply changes to contents?'
      expect(page).not_to have_content "Powered by Hyrax"
      click_on("No. I'll update it manually.")
      within(".panel-heading") do
        expect(page).to have_content('Open Access')
      end
    end
  end

  context 'when form loads' do
    before do
      create(:permission_template_access,
             :deposit,
             permission_template: create(:permission_template, source_id: default_admin_set.id, with_admin_set: true, with_active_workflow: true),
             agent_type: 'user',
             agent_id: user.user_key)
      create(:permission_template_access,
             :deposit,
             permission_template: create(:permission_template, source_id: another_admin_set.id, with_admin_set: true, with_active_workflow: true),
             agent_type: 'user',
             agent_id: user.user_key)
    end

    it 'selects admin set already assigned' do
      visit edit_hyrax_generic_work_path(work)
      click_link "Relationships" # switch tab
      expect(page).to have_select('generic_work_admin_set_id', selected: another_admin_set.title)
    end

    it 'shows license wizard on edit form' do
      visit edit_hyrax_generic_work_path(work)
      expect(page).to have_content("License Wizard")
    end
  end

  shared_examples 'proxy edit work' do
    let(:user) { FactoryBot.create(:user) }
    let(:proxy) { FactoryBot.create(:user) }
    let!(:role1) { Sipity::Role.create(name: 'depositing') }

    let(:work_id) { GenericWork.where(title: 'My Proxy Submitted Work') }
    let(:profile_path) { Hyrax::Engine.routes.url_helpers.user_path(user, locale: 'en') }

    before do
      sign_in user
      visit '/dashboard'
      within 'div#proxy_management' do
        click_link "Manage Proxies"
      end
      sleep(1)
      find('a.select2-choice').click
      find(".select2-input").set(proxy.user_key)
      expect(page).to have_css("div.select2-result-label")
      find("div.select2-result-label").click
      sleep(1)
      logout

      sign_in proxy
      visit new_hyrax_generic_work_path
      title_element = find_by_id("generic_work_title")
      title_element.set("My proxy submitted work")
      fill_in('Creator', with: 'Grantor')
      fill_in('Description', with: 'A proxy deposited work')
      select 'All rights reserved', from: "generic_work_license"
      select(user.user_key, from: 'On behalf of')
      check('agreement')
      click_on('Save')
    end

    it "proxy user edits work" do
      expect(page).to have_link 'Edit'
      click_link 'Edit'
      expect(current_path).to include('edit')
      fill_in('Description', with: 'An edited proxy deposited work')
      fill_in('Creator', with: 'Edited grantor')
      click_on('Save')
      expect(current_path).to include('/concern/generic_works/')
      expect(page).to have_content('An edited proxy deposited work')
      expect(page).to have_content('Edited grantor')
    end
  end
end
