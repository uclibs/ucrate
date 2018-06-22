# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::UploadsController do
  routes { Hyrax::Engine.routes }
  let(:user) { create(:user) }

  describe "#create" do
    let(:file) { fixture_file_upload('/world.png') }
    let(:correct_json_response) { { files: [{ name: "world.png", size: 4218, error: "Virus detected in file" }] }.to_json }

    context "when virus check validation fails" do
      before do
        sign_in user
        allow(Hydra::Works::VirusCheckerService).to receive(:file_has_virus?).and_return(true)
      end
      it "returns json with failure message" do
        post :create, params: { files: [file], format: 'json' }
        expect(response.body).to eq correct_json_response
      end
    end
  end
end
