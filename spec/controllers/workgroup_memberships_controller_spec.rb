require 'rails_helper'
RSpec.describe WorkgroupMembershipsController, type: :controller do

  let(:valid_attributes) { {user_id: 1, workgroup_id: 1, workgroup_role_id: 1} }

  let(:invalid_attributes) { {user_id: nil, workgroup_id: nil, workgroup_role_id: nil} }

  let(:valid_session) { {} }

  let(:valid_workgroup_membership) { create(:workgroup_membership) }

  context "unauthenticated" do
    describe "GET #new" do
      it "redirects the user" do
        get :new
        expect(response).to be_redirect
      end
    end

    describe "GET #edit" do
      it "redirects the user" do
        get :edit, id: valid_workgroup_membership
        expect(response).to be_redirect
      end
    end

    describe "POST #create" do
      it "redirects the user" do
        post :create
        expect(response).to be_redirect
      end
    end

    describe "PUT #update" do
      it "redirects the user" do
        put :update, id: valid_workgroup_membership
        expect(response).to be_redirect
      end
    end
  end

  context "authenticated" do
    let(:user) { FactoryGirl.create(:user) }
    before (:each) { sign_in user }

    describe "GET #new" do
      it "assigns a new workgroup_membership as @workgroup_membership" do
        get :new, {workgroup_membership: valid_attributes, session: valid_session}
        expect(assigns(:workgroup_membership)).to be_a_new(WorkgroupMembership)
      end
    end

    describe "GET #new" do
      it "assigns a new workgroup_membership as @workgroup_membership" do
        get :new, {workgroup_membership: valid_attributes, session: valid_session}
        expect(assigns(:workgroup_membership)).to be_a_new(WorkgroupMembership)
      end
    end

    describe "GET #edit" do
      it "assigns the requested workgroup_membership as @workgroup_membership" do
        workgroup_membership = valid_workgroup_membership
        get :edit, id: workgroup_membership, session: valid_session
        expect(assigns(:workgroup_membership)).to eq(workgroup_membership)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new WorkgroupMembership" do
          expect {
            post :create, {workgroup_membership: valid_attributes, session: valid_session}
          }.to change(WorkgroupMembership, :count).by(1)
        end

        it "assigns a newly created workgroup_membership as @workgroup_membership" do
          post :create, {workgroup_membership: valid_attributes, session: valid_session}
          expect(assigns(:workgroup_membership)).to be_a(WorkgroupMembership)
          expect(assigns(:workgroup_membership)).to be_persisted
        end

        it "redirects to the parent workgroup" do
          post :create, {workgroup_membership: valid_attributes, session: valid_session}
          expect(response).to redirect_to(workgroup_path(id: 1))
        end

        it "initializes the three workgroup roles" do
          post :create, {workgroup_membership: valid_attributes, session: valid_session}
          expect(WorkgroupRole.count).to eq (3)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved workgroup_membership as @workgroup_membership" do
          post :create, {workgroup_membership: invalid_attributes, session: valid_session}
          expect(assigns(:workgroup_membership)).to be_a_new(WorkgroupMembership)
        end

        it "redirects to the workgroups index page" do
          post :create, {workgroup_membership: invalid_attributes, session: valid_session}
          expect(response).to redirect_to(workgroups_path)
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) {
          {user_id: 1, workgroup_id: 1, workgroup_role_id: 1}
        }

        it "updates the requested workgroup_membership" do
          workgroup_membership = valid_workgroup_membership
          put :update, {id: workgroup_membership.to_param, workgroup_membership: new_attributes, session: valid_session}
          workgroup_membership.reload
          expect(workgroup_membership.user_id).to eq(1)
          expect(workgroup_membership.workgroup_id).to eq(1)
          expect(workgroup_membership.workgroup_role_id).to eq(1)
        end

        it "assigns the requested workgroup_membership as @workgroup_membership" do
          workgroup_membership = valid_workgroup_membership
          put :update, {id: workgroup_membership, workgroup_membership: new_attributes, session: valid_session}
          expect(assigns(:workgroup_membership)).to eq(workgroup_membership)
        end

        it "redirects to the parent workgroup" do
          workgroup_membership = valid_workgroup_membership
          put :update, {id: workgroup_membership, workgroup_membership: new_attributes, session: valid_session}
          expect(response).to redirect_to(workgroup_path(id: 1))
        end
      end

      context "with invalid params" do
        it "assigns the workgroup_membership as @workgroup_membership" do
          workgroup_membership = valid_workgroup_membership
          put :update, {id: workgroup_membership.to_param, workgroup_membership: invalid_attributes, session: valid_session}
          expect(assigns(:workgroup_membership)).to eq(workgroup_membership)
        end

        it "redirects to the workgroups index page" do
          workgroup_membership = valid_workgroup_membership
          put :update, {id: workgroup_membership.to_param, workgroup_membership: invalid_attributes, session: valid_session}
          expect(response).to redirect_to(workgroups_path)
        end
      end
    end
  end
end
