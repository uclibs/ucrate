# frozen_string_literal: true
# This tests the Hyrax::WorksControllerBehavior module
# which is included into .internal_test_app/app/controllers/hyrax/generic_works_controller.rb

require 'rails_helper'
RSpec.describe Hyrax::GenericWorksController do
  routes { Rails.application.routes }
  let(:main_app) { Rails.application.routes.url_helpers }
  let(:hyrax) { Hyrax::Engine.routes.url_helpers }
  let(:user) { create(:user) }

  before { sign_in user }

  describe '#create' do
    let(:actor) { instance_double('object', create: create_status) }
    let(:create_status) { true }

    before do
      allow(Hyrax::CurationConcern).to receive(:actor).and_return(actor)
    end

    context 'when create is successful' do
      let(:work) { stub_model(GenericWork) }

      it 'creates a work' do
        allow(controller).to receive(:curation_concern).and_return(work)
        post :create, params: { generic_work: { title: ['a title'], description: 'test description', note: 'test note' } }
        expect(response).to redirect_to main_app.hyrax_generic_work_path(work, locale: 'en')
      end
    end

    context 'when create fails' do
      let(:work) { create(:work) }
      let(:create_status) { false }

      it 'draws the form again' do
        post :create, params: { generic_work: { title: ['a title'], description: 'test description', note: 'test note' } }
        expect(response.status).to eq 422
        expect(assigns[:form]).to be_kind_of Hyrax::GenericWorkForm
        expect(response).to render_template 'new'
      end
    end

    context 'when not authorized' do
      before { allow(controller.current_ability).to receive(:can?).and_return(false) }

      it 'shows the unauthorized message' do
        post :create, params: { generic_work: { title: ['a title'], description: 'test description', note: 'test note' } }
        expect(response.code).to eq '401'
        expect(response).to render_template(:unauthorized)
      end
    end

    context "with files" do
      let(:actor) { object_double('An actor') }
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
            description: 'test description',
            note: 'test note'
          },
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
              generic_work: { title: ['a title'], description: 'test description', note: 'test note' }
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
end
