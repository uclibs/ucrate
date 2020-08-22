# frozen_string_literal: true

require 'rails_helper'
require 'redlock'

RSpec.describe 'Creating a new child Work', :workflow do
  let(:user) { create(:user) }
  let!(:sipity_entity) do
    create(:sipity_entity, proxy_for_global_id: parent.to_global_id.to_s)
  end
  let(:redlock_client_stub) do # stub out redis connection
    client = double('redlock client')
    allow(client).to receive(:lock).and_yield(true)
    allow(Redlock::Client).to receive(:new).and_return(client)
    client
  end
  let!(:parent) { create(:generic_work, user: user, title: ["Parent First"]) }

  before do
    create(:permission_template_access,
           :deposit,
           permission_template: create(:permission_template, with_admin_set: true, with_active_workflow: true),
           agent_type: 'user',
           agent_id: user.user_key)
    sign_in user
    # stub out characterization. Travis doesn't have fits installed, and it's not relevant to the test.
    allow(CharacterizeJob).to receive(:perform_later)
    redlock_client_stub
  end

  it 'creates the child work', clean_repo: true, js: true do
    visit "/concern/parent/#{parent.id}/generic_works/new"
    work_title = 'My Test Work'
    fill_in('Title', with: work_title, match: :first)
    college_element = find_by_id("generic_work_college")
    college_element.select("Business")

    expect(page).to have_content("License Wizard")
    select 'Attribution-ShareAlike 4.0 International', from: 'generic_work_license'

    expect(page).to have_field("Creator", with: user.name_for_works)
    fill_in('Creator', with: 'Doe, Jane')

    fill_in('Program or Department', with: 'University Department')
    fill_in('Description', with: 'This is a description.')

    choose('generic_work_visibility_open')
    check('agreement')
    click_on('Save')
    visit "/concern/generic_works/#{parent.id}"
    expect(page).to have_content work_title
  end

  context "when it's being updated" do
    let(:curation_concern) { create(:generic_work, user: user) }
    let(:new_parent) { create(:generic_work, user: user) }
    let!(:cc_sipity_entity) do
      create(:sipity_entity, proxy_for_global_id: curation_concern.to_global_id.to_s)
    end
    let!(:new_sipity_entity) do
      create(:sipity_entity, proxy_for_global_id: new_parent.to_global_id.to_s)
    end

    before do
      parent.ordered_members << curation_concern
      parent.save!
    end
    it 'can be updated', clean_repo: true, js: true do
      visit "/concern/parent/#{parent.id}/generic_works/#{curation_concern.id}/edit"
      college_element = find_by_id("generic_work_college")
      college_element.select("Business")

      select 'Attribution-ShareAlike 4.0 International', from: 'generic_work_license'

      fill_in('Creator', with: 'Doe, Jane')

      fill_in('Program or Department', with: 'University Department')
      fill_in('Description', with: 'This is a description.')

      choose('generic_work_visibility_open')
      click_on "Save"

      expect(parent.reload.ordered_members.to_a.length).to eq 1
    end
    it "doesn't lose other memberships", clean_repo: true, js: true do
      new_parent.ordered_members << curation_concern
      new_parent.save!

      visit "/concern/parent/#{parent.id}/generic_works/#{curation_concern.id}/edit"
      college_element = find_by_id("generic_work_college")
      college_element.select("Business")

      select 'Attribution-ShareAlike 4.0 International', from: 'generic_work_license'

      fill_in('Creator', with: 'Doe, Jane')

      fill_in('Program or Department', with: 'University Department')
      fill_in('Description', with: 'This is a description.')

      choose('generic_work_visibility_open')
      click_on "Save"

      expect(parent.reload.ordered_members.to_a.length).to eq 1
      expect(new_parent.reload.ordered_members.to_a.length).to eq 1

      expect(curation_concern.reload.in_works_ids.length).to eq 2
    end

    context "with a parent that doesn't belong to this user" do
      let(:new_user) { create(:user) }
      let(:new_parent) { create(:generic_work, user: new_user) }

      it "fails to update" do
        visit "/concern/parent/#{parent.id}/generic_works/#{curation_concern.id}/edit"
        first("input#generic_work_in_works_ids", visible: false).set new_parent.id
        first("input#parent_id", visible: false).set new_parent.id
        click_on "Save"

        expect(new_parent.reload.ordered_members.to_a.length).to eq 0
        expect(page).to have_content "Works can only be related to each other if user has ability to edit both."
      end
    end
  end
end
