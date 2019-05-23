# frozen_string_literal: true
require 'rails_helper'

# This tests the Hyrax::WorksControllerBehavior module
# which is included into .internal_test_app/app/controllers/hyrax/generic_works_controller.rb

RSpec.describe Hyrax::GenericWorksController do
  routes { Rails.application.routes }
  let(:main_app) { Rails.application.routes.url_helpers }
  let(:hyrax) { Hyrax::Engine.routes.url_helpers }
  let(:user) { create(:user) }

  before { sign_in user }

  describe '#create' do
    let(:actor) { double(create: create_status) }
    let(:create_status) { true }

    before do
      allow(Hyrax::CurationConcern).to receive(:actor).and_return(actor)
    end

    context 'when create is successful' do
      let(:work) { stub_model(GenericWork) }

      it 'creates a work' do
        allow(controller).to receive(:curation_concern).and_return(work)
        post :create, params: { generic_work: { title: ['a title'], description: 'a description', note: 'a note' }, permissions_attributes: '' }
        expect(response).to redirect_to main_app.hyrax_generic_work_path(work, locale: 'en')
      end
    end

    context 'when create fails' do
      let(:work) { create(:work) }
      let(:create_status) { false }

      it 'draws the form again' do
        post :create, params: { generic_work: { title: ['a title'], description: 'a description', note: 'a note' }, permissions_attributes: '' }
        expect(response.status).to eq 422
        expect(assigns[:form]).to be_kind_of Hyrax::GenericWorkForm
        expect(response).to render_template 'new'
      end
    end

    context 'when not authorized' do
      before { allow(controller.current_ability).to receive(:can?).and_return(false) }

      it 'shows the unauthorized message' do
        post :create, params: { generic_work: { title: ['a title'], description: 'a description', note: 'a note' }, permissions_attributes: '' }
        expect(response.code).to eq '401'
        expect(response).to render_template(:unauthorized)
      end
    end

    context "with files" do
      let(:actor) { double('An actor') }
      let(:work) { create(:work) }

      before do
        allow(controller).to receive(:actor).and_return(actor)
        # Stub out the creation of the work so we can redirect somewhere
        allow(controller).to receive(:curation_concern).and_return(work)
      end

      it "attaches files" do
        expect(actor).to receive(:create)
          .with(Hyrax::Actors::Environment) do |env|
            expect(env.attributes.keys).to include('uploaded_files')
          end
                     .and_return(true)
        post :create, params: {
          generic_work: {
            title: ["First title"],
            visibility: 'open',
            description: 'a description',
            note: 'a note'
          },
          permissions_params: '',
          uploaded_files: ['777', '888']
        }
        expect(flash[:notice]).to be_html_safe
        expect(flash[:notice]).to eq "Your files are being processed by Scholar@UC in the background. " \
                                     "The metadata and access controls you specified are being applied. " \
                                     "You may need to refresh this page to see these updates."
        expect(response).to redirect_to main_app.hyrax_generic_work_path(work, locale: 'en')
      end

      context "from browse everything" do
        let(:url1) { "https://dl.dropbox.com/fake/blah-blah.filepicker-demo.txt.txt" }
        let(:url2) { "https://dl.dropbox.com/fake/blah-blah.Getting%20Started.pdf" }
        let(:browse_everything_params) do
          { "0" => { "url" => url1,
                     "expires" => "2014-03-31T20:37:36.214Z",
                     "file_name" => "filepicker-demo.txt.txt" },
            "1" => { "url" => url2,
                     "expires" => "2014-03-31T20:37:36.731Z",
                     "file_name" => "Getting+Started.pdf" } }.with_indifferent_access
        end
        let(:uploaded_files) do
          browse_everything_params.values.map { |v| v['url'] }
        end

        context "For a batch upload" do
          # TODO: move this to batch_uploads controller
          it "ingests files from provide URLs" do
            skip "Creating a FileSet without a parent work is not yet supported"
            expect(ImportUrlJob).to receive(:perform_later).twice
            expect do
              post :create, params: { selected_files: browse_everything_params, file_set: {} }
            end.to change(FileSet, :count).by(2)
            created_files = FileSet.all
            expect(created_files.map(&:import_url)).to include(url1, url2)
            expect(created_files.map(&:label)).to include("filepicker-demo.txt.txt", "Getting+Started.pdf")
          end
        end

        context "when a work id is passed" do
          let(:work) do
            create(:work, user: user, title: ['test title'])
          end

          it "records the work" do
            # TODO: ensure the actor stack, called with these params
            # makes one work, two file sets and calls ImportUrlJob twice.
            expect(actor).to receive(:create).with(Hyrax::Actors::Environment) do |env|
              expect(env.attributes['uploaded_files']).to eq []
              expect(env.attributes['remote_files']).to eq browse_everything_params.values
            end

            post :create, params: {
              selected_files: browse_everything_params,
              uploaded_files: uploaded_files,
              parent_id: work.id,
              generic_work: { title: ['First title'], description: 'a description', note: 'a note' },
              permissions_params: ''
            }
            expect(flash[:notice]).to eq "Your files are being processed by Scholar@UC in the background. " \
                                         "The metadata and access controls you specified are being applied. " \
                                         "You may need to refresh this page to see these updates."
            expect(response).to redirect_to main_app.hyrax_generic_work_path(work, locale: 'en')
          end
        end
      end
    end
  end

  describe '#update' do
    let(:work) { stub_model(GenericWork) }
    let(:visibility_changed) { false }
    let(:actor) { double(update: true) }

    before do
      allow(Hyrax::CurationConcern).to receive(:actor).and_return(actor)
      allow(GenericWork).to receive(:find).and_return(work)
      allow(work).to receive(:visibility_changed?).and_return(visibility_changed)
    end

    context "when the user has write access to the file" do
      before do
        allow(controller).to receive(:authorize!).with(:update, work).and_return(true)
      end
      context "when the work has no file sets" do
        it 'updates the work' do
          patch :update, params: { id: work, generic_work: { permissions_attributes: nil } }
          expect(response).to redirect_to main_app.hyrax_generic_work_path(work, locale: 'en')
        end
      end

      context "when the work has file sets attached" do
        before do
          allow(work).to receive(:file_sets).and_return(double(present?: true))
        end
        it 'updates the work' do
          patch :update, params: { id: work, generic_work: { permissions_attributes: nil } }
          expect(response).to redirect_to main_app.hyrax_generic_work_path(work, locale: 'en')
        end
      end

      it "can update file membership" do
        patch :update, params: { id: work, generic_work: { permissions_attributes: nil, ordered_member_ids: ['foo_123'] } }
        expect(actor).to have_received(:update).with(Hyrax::Actors::Environment) do |env|
          expect(env.attributes).to eq("ordered_member_ids" => ['foo_123'],
                                       "remote_files" => [],
                                       "uploaded_files" => [])
        end
      end

      describe 'changing rights' do
        let(:visibility_changed) { true }
        let(:actor) { double(update: true) }

        context 'when the work has file sets attached' do
          before do
            allow(work).to receive(:file_sets).and_return(double(present?: true))
          end
          it 'prompts to change the files access' do
            patch :update, params: { id: work, generic_work: { permissions_attributes: nil } }
            expect(response).to redirect_to main_app.confirm_hyrax_permission_path(controller.curation_concern, locale: 'en')
          end
        end

        context 'when the work has no file sets' do
          it "doesn't prompt to change the files access" do
            patch :update, params: { id: work, generic_work: { permissions_attributes: nil } }
            expect(response).to redirect_to main_app.hyrax_generic_work_path(work, locale: 'en')
          end
        end
      end

      describe 'update failed' do
        let(:actor) { double(update: false) }

        it 'renders the form' do
          patch :update, params: { id: work, generic_work: { permissions_attributes: nil } }
          expect(assigns[:form]).to be_kind_of Hyrax::GenericWorkForm
          expect(response).to render_template('edit')
        end
      end
    end

    context 'someone elses public work' do
      let(:work) { create(:public_generic_work) }

      it 'shows the unauthorized message' do
        get :update, params: { id: work }
        expect(response.code).to eq '401'
        expect(response).to render_template(:unauthorized)
      end
    end
  end
end
