# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Dashboard::CollectionsController, :clean_repo do
  routes { Hyrax::Engine.routes }
  let(:user)  { create(:user) }
  let(:other) { build(:user) }
  let(:collection_type_gid) { create(:user_collection_type).gid }

  let(:asset1)         { create(:work, title: ["First of the Assets"], user: user) }
  let(:asset2)         { create(:work, title: ["Second of the Assets"], user: user) }
  let(:unowned_asset)  { create(:work, user: other) }

  let(:collection_attrs) do
    { collection: { title: "title",
                    creator: ["creator"],
                    description: "desc",
                    license: "http://rightsstatements.org/vocab/InC/1.0/",
                    permissions_attributes: [{ type: 'person', name: 'archivist1', access: 'edit' }] },
      collection_type_gid: collection_type_gid }
  end

  describe '#create' do
    before { sign_in user }

    # rubocop:disable RSpec/ExampleLength
    it "creates a Collection" do
      expect do
        post :create, params: collection_attrs
      end.to change { Collection.count }.by(1)
      expect(assigns[:collection].visibility).to eq 'open'
      expect(assigns[:collection].edit_users).to contain_exactly "archivist1", user.email
      expect(flash[:notice]).to eq "Collection was successfully created."
    end

    context "when create fails" do
      let(:collection) { Collection.new }

      before do
        allow(controller).to receive(:authorize!)
        allow(Collection).to receive(:new).and_return(collection)
        allow(collection).to receive(:save).and_return(false)
      end

      it "renders the form again" do
        post :create, params: { collection: collection_attrs }
        expect(response).to be_successful
        expect(response).to render_template(:new)
      end
    end
  end
end
