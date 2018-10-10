# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::BatchUploadsController do
  routes { Hyrax::Engine.routes }
  let(:user) { create(:user) }
  let(:expected_types) do
    { '1' => 'Article',
      '2' => ['Article', 'Text'] }
  end
  let(:expected_individual_params) do
    { '1' => 'foo',
      '2' => 'bar' }
  end
  let(:expected_shared_params) do
    { 'visibility' => 'open', :model => 'GenericWork' }
  end
  let(:batch_upload_item) do
    { visibility: 'open', payload_concern: 'GenericWork' }
  end
  let(:post_params) do
    {
      title: expected_individual_params,
      resource_type: expected_types,
      uploaded_files: ['1', '2'],
      batch_upload_item: batch_upload_item
    }
  end

  before do
    sign_in user
  end

  describe "#create" do
    context 'when feature is disabled' do
      before do
        allow(Flipflop).to receive(:batch_upload?).and_return(false)
      end
      it 'redirects with an error message' do
        post :create, params: post_params.merge(format: :html)
        expect(response).to redirect_to Hyrax::Engine.routes.url_helpers.my_works_path(locale: 'en')
        expect(flash[:alert]).to include('Feature disabled by administrator')
      end
      context 'when json is requested' do
        it 'returns an HTTP 403' do
          post :create, params: post_params.merge(format: :json)
          expect(response).to have_http_status(403)
          expect(response.body).to include('Feature disabled by administrator')
        end
      end
    end

    context "with expected params" do
      it 'spawns a job, redirects to dashboard, and has an html_safe flash notice' do
        expect(BatchCreateJob).to receive(:perform_later)
          .with(user,
                expected_individual_params,
                ['1', '2'],
                expected_shared_params,
                Hyrax::BatchCreateOperation)
        post :create, params: post_params
        expect(response).to redirect_to Hyrax::Engine.routes.url_helpers.my_works_path(locale: 'en')
        expect(flash[:notice]).to be_html_safe
        expect(flash[:notice]).to include("Your files are being processed")
      end
    end

    context "when submitting works on behalf of other user" do
      let(:batch_upload_item) do
        {
          payload_concern: 'GenericWork',
          permissions_attributes: [
            { type: "group", name: "public", access: "read" }
          ],
          on_behalf_of: 'elrayle'
        }
      end

      it 'redirects to managed works page' do
        allow(BatchCreateJob).to receive(:perform_later)
        post :create, params: post_params
        expect(response).to redirect_to Hyrax::Engine.routes.url_helpers.dashboard_works_path(locale: 'en')
      end
    end
    context "with blank payload_concern param" do
      let(:batch_upload_item) do
        {}
      end

      it 'returns not found' do
        allow(BatchCreateJob).to receive(:perform_later)
        expect { get :new, params: post_params }.to raise_error(ActionController::RoutingError)
      end
    end

    context "with bad payload_concern param" do
      let(:batch_upload_item) do
        { payload_concern: 'foo' }
      end

      it 'returns not found' do
        allow(BatchCreateJob).to receive(:perform_later)
        expect { get :new, params: post_params }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
