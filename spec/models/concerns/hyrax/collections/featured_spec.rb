# frozen_string_literal: true

require 'rails_helper'
RSpec.describe ::Hyrax::Collections::Featured do
  let(:user) { FactoryBot.create(:user) }
  let(:collection) { create(:public_collection, user: user) }
  let!(:featured_collection) { FeaturedCollection.create(collection_id: collection.id).save }

  context "When collection is featured" do
    it "removes featured collection object when collection is deleted" do
      collection.destroy
      expect(FeaturedCollection.count).to eq(0)
    end
  end
end
