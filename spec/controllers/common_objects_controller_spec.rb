# frozen_string_literal: true

require 'rails_helper'

describe CommonObjectsController do
  let(:work) { create :work }
  let(:collection) { create :collection }
  let(:deleted_work) { create :work }

  describe '#show' do
    context 'with valid work' do
      it 'redirects to the work path' do
        get :show, params: { id: work.id }
        expect(response.status).to eq(302)
      end
    end

    context 'with a valid collection' do
      it 'redirects to the collection path' do
        get :show, params: { id: collection.id }
        expect(response.status).to eq(302)
      end
    end

    context 'with invalid pid' do
      it 'returns a 404 error' do
        get :show, params: { id: 'foo' }
        expect(response.status).to eq(404)
      end
    end

    context 'with a deleted work' do
      before do
        deleted_work.delete
      end

      it 'returns a 404 error' do
        get :show, params: { id: deleted_work.id }
        expect(response.status).to eq(404)
      end
    end
  end
end
