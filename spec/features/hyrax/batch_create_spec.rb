# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Batch creation of works', type: :feature do
  let(:user) { create(:user) }
  let!(:default_admin_set) do
    build(:admin_set,
          id: AdminSet::DEFAULT_ID,
          title: ["Default Admin Set"],
          description: ["A description"],
          with_permission_template: { deposit_groups: [::Ability.registered_group_name] })
  end

  before do
    # stub out characterization and derivatives. Travis doesn't have fits installed, and it's not relevant to the test.
    allow(CharacterizeJob).to receive(:perform_later)
    allow(CreateDerivativesJob).to receive(:perform_later)

    sign_in user
  end

  it "renders the batch create form" do
    visit hyrax.new_batch_upload_path(payload_concern: 'Document')
    expect(page).to have_content "Add New Works by Batch"
    within("li.active") do
      expect(page).to have_content("Files")
    end
    expect(page).to have_content("Each file will be uploaded to a separate new work resulting in one work per uploaded file.")
  end

  it 'defaults to public visibility' do
    visit hyrax.new_batch_upload_path(payload_concern: 'Document')
    expect(page).to have_checked_field('batch_upload_item_visibility_open')
  end

  it 'hides cloud upload button' do
    visit hyrax.new_batch_upload_path(payload_concern: 'Document')
    expect(page).to have_no_content('Add cloud files')
  end

  context 'when the user is a proxy', :js, :workflow do
    let(:second_user) { create(:user) }

    before do
      create(:permission_template_access,
             :deposit,
             permission_template: create(:permission_template, with_admin_set: true, with_active_workflow: true),
             agent_type: 'user',
             agent_id: user.user_key)
      ProxyDepositRights.create!(grantor: second_user, grantee: user)
      sign_in user
      visit '/dashboard'
      within('.sidebar') do
        click_link 'Works'
      end
      click_link "Create batch of works"
    end

    it "allows on-behalf-of batch deposit", :js do
      skip
      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      within('span#addfiles') do
        # two arbitrary files that aren't actually related, but should be
        # small enough to require minimal processessing.
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/small_file.txt", visible: false)
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/png_fits.xml", visible: false)
      end
      click_link "Metadata" # switch tab
      fill_in('Creator', with: 'Doe, Jane')
      fill_in('Keyword', with: 'testing')
      select('In Copyright', from: 'Rights statement')

      choose('batch_upload_item_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Open Access) may be viewed as publishing which could impact your ability to')
      select(second_user.user_key, from: 'On behalf of')
      check('agreement')
      click_on('Save')

      # Expect the proxy depositor (grantor) to be able to see both uploaded files.
      expect(page).to have_content 'small_file.txt'
      expect(page).to have_content 'png_fits.xml'

      # Sign in with the grantee user, and expect to see the works deposited
      # on their behalf.
      sign_in second_user
      click_link 'Works'
      expect(page).to have_content 'small_file.txt'
      expect(page).to have_content 'png_fits.xml'
    end
  end
end
