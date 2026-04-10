# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::CollectionPresenter do
  let(:ability) { instance_double(Ability, current_user: nil) }
  let(:solr_document) do
    instance_double(
      SolrDocument,
      id: 'col1',
      collection_type_gid: 'gid://internal/Hyrax-CollectionType/1'
    )
  end
  let(:presenter) { described_class.new(solr_document, ability) }
  let(:collection_type) do
    instance_double(
      Hyrax::CollectionType,
      title: type_title,
      badge_color: '#705070',
      user_collection?: true,
      admin_set?: false,
      machine_id: 'user_collection'
    )
  end

  before do
    allow(presenter).to receive(:collection_type).and_return(collection_type)
  end

  describe '#collection_type_badge' do
    context 'when the type title in the DB is a stale i18n error string' do
      let(:type_title) { 'translation missing: en.hyrax.collection_type.default_title' }

      it 'shows the localized default title' do
        html = presenter.collection_type_badge
        expect(html).to include('User Collection')
        expect(html).not_to include('translation missing')
      end
    end

    context 'when the type title is normal' do
      let(:type_title) { 'My Custom Type' }

      it 'uses the stored title' do
        expect(presenter.collection_type_badge).to include('My Custom Type')
      end
    end
  end
end
