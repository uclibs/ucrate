require 'rails_helper'
RSpec.describe WorkgroupsController, type: :controller do

  ## Using fac
  let(:valid_attributes) {  }

  let(:invalid_attributes) { skip "need to define invalid attributes" }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # WorkgroupsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:valid_workgroup) { create(:workgroup) }

  context "unauthenticated" do
    describe "GET #index" do
      it "redirects the user" do
        get :index
        expect(response).to be_redirect
      end
    end

    describe "GET #show" do
      it "redirects the user" do
        get :show, id: valid_workgroup
        expect(response).to be_redirect
      end
    end

    describe "GET #new" do
      it "redirects the user" do
        get :new
        expect(response).to be_redirect
      end
    end

    describe "GET #edit" do
      it "redirects the user" do
        get :edit, id: valid_workgroup
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
        put :update, id: valid_workgroup
        expect(response).to be_redirect
      end
    end
  end

  context "authenticated" do
    let(:user) { FactoryGirl.create(:user) }
    before (:each) { sign_in user }

    describe "GET #index" do
      it "assigns all workgroups as @workgroups" do
        workgroup = valid_workgroup
        get :index, params: {}, session: valid_session
        expect(assigns(:workgroups)).to eq([workgroup])
      end
    end

    describe "GET #show" do
      it "assigns the requested workgroup as @workgroup" do
        workgroup = valid_workgroup
        get :show, id: workgroup, session: valid_session
        expect(assigns(:workgroup)).to eq(workgroup)
      end
    end

    describe "GET #new" do
      it "assigns a new workgroup as @workgroup" do
        get :new, params: {}, session: valid_session
        expect(assigns(:workgroup)).to be_a_new(Workgroup)
      end
    end

    describe "GET #edit" do
      it "assigns the requested workgroup as @workgroup" do
        workgroup = valid_workgroup
        get :edit, id: workgroup, session: valid_session
        expect(assigns(:workgroup)).to eq(workgroup)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new Workgroup" do
          ## TODO Implement valid_attributes, once defined
          expect {
            post :create, params: {}, session: valid_session
          }.to change(Workgroup, :count).by(1)
        end

        it "assigns a newly created workgroup as @workgroup" do
          ## TODO Implement valid_attributes, once defined
          post :create, params: {}, session: valid_session
          expect(assigns(:workgroup)).to be_a(Workgroup)
          expect(assigns(:workgroup)).to be_persisted
        end

        it "redirects to the created workgroup" do
          ## TODO Implement valid_attributes, once defined
          post :create, params: {}, session: valid_session
          expect(response).to redirect_to(Workgroup.last)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved workgroup as @workgroup" do
          post :create, params: {workgroup: invalid_attributes}, session: valid_session
          expect(assigns(:workgroup)).to be_a_new(Workgroup)
        end

        it "re-renders the 'new' template" do
          skip("need to define invalid params")
          post :create, params: {workgroup: invalid_attributes}, session: valid_session
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) {
          skip("No attributes yet defined")
        }

        it "updates the requested workgroup" do
          workgroup = valid_workgroup
          put :update, params: {id: workgroup.to_param, workgroup: new_attributes}, session: valid_session
          workgroup.reload
          skip("Add assertions for updated state")
        end

        it "assigns the requested workgroup as @workgroup" do
          workgroup = valid_workgroup
          put :update, id: workgroup, session: valid_session
          expect(assigns(:workgroup)).to eq(workgroup)
        end

        it "redirects to the workgroup" do
          workgroup = valid_workgroup
          put :update, id: workgroup, session: valid_session
          expect(response).to redirect_to(workgroup)
        end
      end

      context "with invalid params" do
        it "assigns the workgroup as @workgroup" do
          workgroup = valid_workgroup
          put :update, params: {id: workgroup.to_param, workgroup: invalid_attributes}, session: valid_session
          expect(assigns(:workgroup)).to eq(workgroup)
        end

        it "re-renders the 'edit' template" do
          workgroup = valid_workgroup
          put :update, params: {id: workgroup.to_param, workgroup: invalid_attributes}, session: valid_session
          expect(response).to render_template("edit")
        end
      end
    end
  end
end
