# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "collection export", type: :feature do
  context "not logged in" do
    it "cannot see the export page" do
      visit "/dashboard/collection_exports"
      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end

  context "logged in" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    let!(:user_collection) do
      create(:public_collection,
             user: user,
             description: ['collection description'],
             collection_type_settings: :nestable)
    end

    let!(:user_work) do
      create(:work, title: ["King Louie"], member_of_collections: [user_collection], user: user)
    end
    let!(:other_user_work) do
      create(:work, title: ["King Kong"], member_of_collections: [user_collection],  user: other_user)
    end

    context "collections that the user created" do
      it "do all the things we expect", :clean_repo do
        skip
        sign_in user
        visit "dashboard/my/collections"
        # can export a collection from the dashboard collection index
        click_link "Export collection"
        expect(page).to have_content("Collection export was successfully created")
        expect(page).to have_content(user_collection.id)
        expect(page).to have_content(user_collection.title.first)

        # can export a collection from the dashboard collection index
        # visit "dashboard/my/collections"
        # click_link "View collection"
        # click_button "Export collection"
        # expect(page).to have_content("Collection export was successfully created")
        # expect(page).to have_content(collection.id)

        # can download a collection from the collection export index
        click_link "Download"
        expect(page.html.class).to eq String
        expect(!!(page.html =~ /King Louie/)).to be true
        expect(!!(page.html =~ /King Kong/)).to be true

        # can delete a collection from the collection export index
        visit "/dashboard/collection_exports"
        click_link "Delete"
        expect(page).to have_content("Collection export was successfully deleted")
      end
    end

    context "collection exports that someone else created" do
      context "for a collection you can see", :clean_repo do
        let(:public_other_user_collection) do
          create(:public_collection,
                 user: other_user,
                 description: ['collection description'],
                 collection_type_settings: :nestable)
        end

        before do
          CollectionExport.create(collection_id: public_other_user_collection.id,
                                  user: other_user.email,
                                  export_file: File.open(Rails.root.join('spec', 'fixtures', 'export.csv')).read)
        end

        it "do all the things we expect" do
          sign_in user
          visit "/dashboard/collection_exports"

          # can see a collection export I didn't create for a collection I can see
          expect(page).to have_link("Download")

          # can not delete a collection export I didn't create for a collection I can see
          expect(page).not_to have_link("Delete")
        end
      end

      context "for a collection you can not see" do
        let(:private_other_user_collection) do
          create(:collection,
                 user: other_user,
                 description: ['collection description'],
                 collection_type_settings: :nestable)
        end

        before do
          CollectionExport.create(collection_id: private_other_user_collection.id,
                                  user: other_user.email,
                                  export_file: File.open(Rails.root.join('spec', 'fixtures', 'export.csv')).read)
        end

        it "do all the things we expect", :clean_repo do
          sign_in user
          visit "dashboard/collection_exports"

          # can not see a collection export I didn't create for a collection I can not see
          expect(page).not_to have_link("Download")

          # can not delete a collection export I didn't create for a collection I can not see
          expect(page).not_to have_link("Delete")
        end
      end
    end

    context "collection exports for which the collection doesn't exist", :clean_repo do
      before do
        CollectionExport.create(collection_id: "invalid_pid",
                                user: user.email,
                                export_file: File.open(Rails.root.join('spec', 'fixtures', 'export.csv')).read)
      end

      it "can still see the collection when logged in" do
        sign_in user
        visit "dashboard/collection_exports"

        expect(page).to have_link("Download")
        expect(page).to have_link("Delete")
      end
    end
  end
end
