# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'batch', type: :feature, clean_repo: true, js: true do
  let(:current_user) { create(:user) }
  let(:admin_set) { create(:admin_set) }
  let(:permission_template) { create(:permission_template, source_id: admin_set.id) }
  let!(:workflow) { create(:workflow, allows_access_grant: true, active: true, permission_template_id: permission_template.id) }

  let!(:work1)       { create(:public_work, admin_set_id: admin_set.id, user: current_user, members: [file_set]) }
  let!(:work2)       { create(:public_work, admin_set_id: admin_set.id, user: current_user) }
  let!(:file_set)    { create(:file_set) }

  before do
    donor = Role.find_or_create_by(name: "donor")
    donor.users << current_user
    donor.save
    sign_in current_user
    visit '/dashboard/my/works'
    check 'check_all'
  end

  describe 'editing' do
    it 'changes the value of each field for all selected works' do
      skip
      click_on 'batch-edit'
      fill_in_batch_edit_fields_and_verify!
      work1.reload
      work2.reload
      batch_edit_fields.each do |field|
        expect(work1.send(field)).to match_array("NEW #{field}")
        expect(work2.send(field)).to match_array("NEW #{field}")
      end

      # Reload the form and verify
      visit '/dashboard/my/works'
      check 'check_all'
      find('#batch-edit').click
      expect(page).to have_content('Batch Edit Descriptions')
      batch_edit_expand("creator") do
        sleep 1
        page.find("input#generic_work_creator[value='NEW creator']")
      end
      batch_edit_expand("contributor") do
        sleep 1
        page.find("input#generic_work_contributor[value='NEW contributor']")
      end
      batch_edit_expand("description") do
        sleep 1
        page.find("textarea#generic_work_description", text: 'NEW description')
      end
      batch_edit_expand("publisher") do
        sleep 1
        page.find "input#generic_work_publisher[value='NEW publisher']"
      end
      batch_edit_expand("date_created") do
        sleep 1
        page.find("input#generic_work_date_created[value='NEW date_created']")
      end
      batch_edit_expand("subject") do
        sleep 1
        page.find("input#generic_work_subject[value='NEW subject']")
      end
      batch_edit_expand("language") do
        sleep 1
        page.find("input#generic_work_language[value='NEW language']")
      end
      batch_edit_expand("identifier") do
        sleep 1
        page.find("input#generic_work_identifier[value='NEW identifier']")
      end
      # batch_edit_expand("based_near")
      # expect(page).to have_css "input#generic_work_based_near[value*='NEW based_near']"
      batch_edit_expand("related_url") do
        sleep 1
        page.find("input#generic_work_related_url[value='NEW related_url']")
      end
    end

    it 'updates permissions and roles', retry: 3, retry_wait: 10 do
      click_on 'batch-edit'
      find('#edit_permissions_link').click
      expect(page).to have_content('Batch Edit Descriptions')

      # Set visibility to private
      within "#form_permissions_visibility" do
        batch_edit_expand('permissions_visibility')
        find('#generic_work_visibility_authenticated').click
        find('#permissions_visibility_save').click
        # This was `expect(page).to have_content 'Changes Saved'`, however in debugging,
        # the `have_content` check was ignoring the `within` scoping and finding
        # "Changes Saved" for other field areas
        find('.status', text: 'Changes Saved', wait: 10)
      end

      # Visit work permissions and verify
      visit "/concern/generic_works/#{work1.id}/edit#share"
      page.find('#generic_work_visibility_authenticated:checked')

      # Visit file permissions and verify
      visit "concern/file_sets/#{work1.file_sets.first.id}/edit#permissions_display"
      page.find('#file_set_visibility_authenticated:checked')
    end
  end

  describe 'deleting' do
    it 'destroys the selected works' do
      accept_confirm { click_button 'Delete Selected' }
      expect(GenericWork.count).to be_zero
    end
  end
end
