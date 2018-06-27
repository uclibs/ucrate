# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::FileSetsController do
  routes { Rails.application.routes }
  let(:user) { create(:user) }
  let(:actor) { controller.send(:actor) }

  context "when signed in" do
    before do
      sign_in user
    end

    describe "#show" do
      let(:file_set) do
        create(:file_set, title: ['test file'], user: user)
      end

      context "without a referer" do
        it "shows me the file and set breadcrumbs" do
          expect(controller).to receive(:add_breadcrumb).with('Home', Hyrax::Engine.routes.url_helpers.root_path(locale: 'en'))
          expect(controller).to receive(:add_breadcrumb).with(I18n.t('hyrax.dashboard.title'), Hyrax::Engine.routes.url_helpers.dashboard_path(locale: 'en'))
          get :show, params: { id: file_set }
          expect(response).to be_successful
          expect(flash).to be_empty
          expect(assigns[:presenter]).to be_kind_of Hyrax::FileSetPresenter
          expect(assigns[:presenter].id).to eq file_set.id
          expect(assigns[:presenter].events).to be_kind_of Array
          expect(assigns[:presenter].fixity_check_status).to eq 'Fixity checks have not yet been run on this object'
        end
      end
    end
  end
end
