# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionExportsController, type: :controller do
  let(:user) { create(:user) }
  let(:collection) { create(:collection) }
  let(:collection_attributes) { { collection_id: collection.id } }

  context "when the user is not logged in" do
    describe "GET #index" do
      it "redirects to the login page" do
        get :index, params: {}
        expect(response).to redirect_to(new_user_session_path.sub("?locale=en", ""))
      end
    end
  end

  context "when the user is logged in" do
    before do
      sign_in user

      CollectionExportsController.any_instance.stub(
        :new_collection_export_file
      ).and_return(File.open(Rails.root.join('spec', 'fixtures', 'export.csv')))

      @controller.stub(:current_ability).and_return(ability)
    end

    context "when the user is able" do
      let(:ability) do
        ability = Object.new
        ability.extend(CanCan::Ability)
        ability.can :show, Collection
        ability.can :show, CollectionExport
        ability.can :destroy, CollectionExport
        ability
      end

      describe "GET #index" do
        it "returns a success response" do
          CollectionExport.create! collection_attributes
          get :index, params: {}
          expect(response).to be_success
        end
      end

      describe "GET #download" do
        it "returns a success response" do
          collection_export = CollectionExport.create! collection_attributes
          get :download, params: { id: collection_export.id }
          expect(response).to be_success
        end
      end

      describe "POST #create" do
        context "with valid params" do
          it "creates a new CollectionExport" do
            expect do
              post :create, params: collection_attributes
            end.to change(CollectionExport, :count).by(1)
          end

          it "redirects to the collection_exports list" do
            post :create, params: collection_attributes
            expect(response).to redirect_to(collection_exports_url)
          end
        end
      end

      describe "DELETE #destroy" do
        it "destroys the requested collection_export" do
          collection_export = CollectionExport.create! collection_attributes
          expect do
            delete :destroy, params: { id: collection_export.to_param }
          end.to change(CollectionExport, :count).by(-1)
        end

        it "redirects to the collection_exports list" do
          collection_export = CollectionExport.create! collection_attributes
          delete :destroy, params: { id: collection_export.to_param }
          expect(response).to redirect_to(collection_exports_url)
        end
      end
    end

    context "when the user is not able" do
      let(:ability) do
        ability = Object.new
        ability.extend(CanCan::Ability)
        ability
      end

      describe "GET #index" do
        it "returns a success response" do
          CollectionExport.create! collection_attributes
          get :index, params: {}
          expect(response).to be_success
        end
      end

      describe "GET #download" do
        it "returns a 403 response" do
          collection_export = CollectionExport.create! collection_attributes
          get :download, params: { id: collection_export.id }
          assert_response(403)
        end
      end

      describe "POST #create" do
        it "returns a 403 response" do
          post :create, params: collection_attributes
          assert_response(403)
        end
      end

      describe "DELETE #destroy" do
        it "returns a 403 response" do
          collection_export = CollectionExport.create! collection_attributes
          delete :destroy, params: { id: collection_export.to_param }
          assert_response(403)
        end
      end
    end
  end
end
