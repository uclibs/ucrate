# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'collection', type: :feature, js: true, clean_repo: true do
  let(:user) { create(:user) }

  let(:collection1) { create(:public_collection, user: user) }
  let(:collection2) { create(:public_collection, user: user) }

  describe 'collection show page' do
    let(:collection) do
      create(:public_collection, user: user, license: 'http://creativecommons.org/licenses/by-nc-nd/4.0/', description: ['collection description'], collection_type_settings: :nestable)
    end
    let!(:work1) { create(:work, title: ["King Louie"], member_of_collections: [collection], user: user) }
    let!(:work2) { create(:work, title: ["King Kong"], member_of_collections: [collection], user: user) }
    let!(:col1) { create(:public_collection, title: ["Sub-collection 1"], member_of_collections: [collection], user: user) }
    let!(:col2) { create(:public_collection, title: ["Sub-collection 2"], member_of_collections: [collection], user: user) }

    before do
      sign_in user
      visit "/collections/#{collection.id}"
    end

    it "shows permalinks" do
      expect(page).to have_content("Link to this page")
    end

    it "shows a collection with a listing of Descriptive Metadata and catalog-style search results" do
      expect(page).to have_content(collection.title.first)
      expect(page).to have_content(collection.description.first)
      expect(page).to have_content(collection.license.first)
      expect(page).to have_content("Collection Details")
      # Should not show title and description a second time
      expect(page).not_to have_css('.metadata-collections', text: collection.title.first)
      expect(page).not_to have_css('.metadata-collections', text: collection.description.first)
      # Should have search results / contents listing
      expect(page).to have_content(work1.title.first)
      expect(page).to have_content(work2.title.first)
      expect(page).to have_content(col1.title.first)
      expect(page).to have_content(col2.title.first)
      expect(page).not_to have_css(".pagination")

      click_link "Gallery"
      expect(page).to have_content(work1.title.first)
      expect(page).to have_content(work2.title.first)
    end

    it "hides collection descriptive metadata when searching a collection" do
      expect(page).to have_content(collection.title.first)
      expect(page).to have_content(collection.description.first)
      expect(page).to have_content(work1.title.first)
      expect(page).to have_content(work2.title.first)
      fill_in('collection_search', with: work1.title.first)
      click_button('collection_submit')
      # Should not have Collection metadata table (only title and description)
      expect(page).not_to have_content("Total works")
      expect(page).to have_content(collection.title.first)
      expect(page).to have_content(collection.description.first)
      # Should have search results / contents listing
      expect(page).to have_content("Search Results")
      expect(page).to have_content(work1.title.first)
      expect(page).not_to have_content(work2.title.first)
    end

    context "with a non-nestable collection type" do
      let(:collection) do
        build(:public_collection_lw, user: user, description: ['collection description'], collection_type_settings: :not_nestable, with_solr_document: true, with_permission_template: true)
      end

      it "displays basic information on its show page" do
        expect(page).to have_content(collection.title.first)
        expect(page).to have_content(collection.description.first)
        expect(page).to have_content("Collection Details")
      end
    end
  end

  # TODO: this is just like the block above. Merge them.
  describe 'show work pages of a collection' do
    before do
      docs = (0..12).map do |n|
        { "has_model_ssim" => ["GenericWork"], :id => "zs25x871q#{n}",
          "depositor_ssim" => [user.user_key],
          "suppressed_bsi" => false,
          "member_of_collection_ids_ssim" => [collection.id],
          "nesting_collection__parent_ids_ssim" => [collection.id],
          "edit_access_person_ssim" => [user.user_key] }
      end
      ActiveFedora::SolrService.add(docs, commit: true)

      sign_in user
    end
    let(:collection) { create(:named_collection, user: user) }

    it "shows a collection with a listing of Descriptive Metadata and catalog-style search results" do
      visit "/collections/#{collection.id}"
      expect(page).to have_css(".pagination")
    end
  end

  describe 'show subcollection pages of a collection' do
    before do
      docs = (0..12).map do |n|
        { "has_model_ssim" => ["Collection"], :id => "zs25x871q#{n}",
          "depositor_ssim" => [user.user_key],
          "suppressed_bsi" => false,
          "member_of_collection_ids_ssim" => [collection.id],
          "nesting_collection__parent_ids_ssim" => [collection.id],
          "edit_access_person_ssim" => [user.user_key] }
      end
      ActiveFedora::SolrService.add(docs, commit: true)

      sign_in user
    end
    let(:collection) { create(:named_collection, user: user) }

    it "shows a collection with a listing of Descriptive Metadata and catalog-style search results" do
      visit "/collections/#{collection.id}"
      expect(page).to have_css(".pagination")
    end
  end
end
