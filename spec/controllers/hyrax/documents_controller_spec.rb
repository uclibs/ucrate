# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Document`
require 'rails_helper'

RSpec.describe Hyrax::DocumentsController, type: :controller do
  routes { Hyrax::Engine.routes }
  include Hyrax::Engine.routes.url_helpers

  let(:user) { create(:user) }
  let(:document) { create(:document) }

  before do
    sign_in user
  end

  describe 'GET #show' do
    before do
      # Assuming that your document factory does save the object.
      # Force create the document if it's not persisted.
      document.save unless document.persisted?
    end
    it 'assigns the expected curation_concern_type' do
      expect(Hyrax::DocumentsController.curation_concern_type).to eq(::Document)
    end

    it 'assigns the expected show_presenter' do
      expect(controller.class.show_presenter).to eq(Hyrax::DocumentPresenter)
    end

    it 'assigns @permalinks_presenter' do
      get :show, params: { id: document.id }
      expect(assigns(:permalinks_presenter)).to be_a(PermalinksPresenter)
      expect(assigns(:permalinks_presenter).permalinks_url).to eq(hyrax_document_path(document, locale: nil))
      expect(assigns(:permalinks_presenter).permalink_message).to eq(I18n.t('permanent_link_label'))
    end
  end
end
