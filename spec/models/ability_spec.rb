# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  it 'responds to :custom_permissions' do
    expect(described_class.method_defined?(:custom_permissions)).to be true
  end

  describe "CollectionExport" do
    subject(:ability) { Ability.new(user) }
    let(:user) { create(:user) }

    let(:user_collection) { create(:collection, user: user) }
    let(:other_collection) { create(:collection) }

    context "if the user created the collection export, but the collection has been deleted" do
      let(:collection_export) { CollectionExport.create(user: user.email, collection_id: user_collection.id) }

      before { user_collection.destroy }

      it { is_expected.to be_able_to(:show, collection_export) }
      it { is_expected.to be_able_to(:destroy, collection_export) }
    end

    context "if another user created the collection export, but the collection has been deleted" do
      let(:collection_export) { CollectionExport.create(collection_id: user_collection.id) }

      before { user_collection.destroy }

      it { is_expected.not_to be_able_to(:show, collection_export) }
      it { is_expected.not_to be_able_to(:destroy, collection_export) }
    end

    context "if the user did not create the collection export" do
      context "if the user can :show the related collection" do
        let(:collection_export) { CollectionExport.create(user: "test@example.com", collection_id: user_collection.id) }

        it { is_expected.to be_able_to(:show, collection_export) }
      end

      context "if the user can :destroy the related collection" do
        let(:collection_export) { CollectionExport.create(user: "test@example.com", collection_id: user_collection.id) }

        it { is_expected.to be_able_to(:destroy, collection_export) }
      end

      context "if the user can not :show the related collection" do
        let(:collection_export) { CollectionExport.create(user: "test@example.com", collection_id: other_collection.id) }

        it { is_expected.not_to be_able_to(:show, collection_export) }
      end

      context "if the user can not :destroy the related collection" do
        let(:collection_export) { CollectionExport.create(user: "test@example.com", collection_id: other_collection.id) }

        it { is_expected.not_to be_able_to(:destroy, collection_export) }
      end
    end
  end
end
