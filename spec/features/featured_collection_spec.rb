# frozen_string_literal: true
require 'rails_helper'

describe 'collection', type: :feature, js: true do
  let(:user) { create(:admin) }
  let(:admin_set) do
    create(:admin_set, id: AdminSet::DEFAULT_ID,
                       title: ["Default Admin Set"],
                       description: ["A description"],
                       edit_users: [user.user_key])
  end
  let(:collection) { create(:public_collection, user: user) }
  let!(:work) { create(:generic_work_with_one_file, :public, member_of_collections: [collection]) }
  let(:title) { work.file_sets.first.title.first }
  let(:file_id) { work.file_sets.first.id }

  describe 'featuring a collection' do
    before do
      admin = Role.find_or_create_by(name: "admin")
      admin.users << user
      admin.save

      # Grant the user access to deposit into the admin set.
      create(:permission_template_access,
             :deposit,
             permission_template: create(:permission_template, with_admin_set: true, with_active_workflow: true),
             agent_type: 'user',
             agent_id: user.user_key)

      # stub out characterization. Travis doesn't have fits installed, and it's not relevant to the test.
      allow(CharacterizeJob).to receive(:perform_later)

      sign_in user
      collection.thumbnail_id = file_id
      collection.save
    end

    it "displays message when no collection featured" do
      visit '/'
      expect(page).to have_content('No collections have been featured')
    end

    it "displays featured collection image on homepage" do
      visit hyrax.dashboard_collection_path(collection)
      click_link("Feature")
      visit '/'
      expect(page).to have_css("img[alt='Thumbnail for featured collection: #{collection.title.first}")
    end
  end
end
