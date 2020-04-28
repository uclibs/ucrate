# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe 'catalog/_index_header_list_collection', type: :view do
  let(:id) { '123' }
  let(:collection) { create(:collection, id: id) }
  let(:collection_doc) { SolrDocument.new(id: id, has_model_ssim: 'Collection', collection_type_gid_ssim: collection.collection_type_gid) }
  let(:collection_type) { create(:collection_type) }
  let(:user_collection_type) { create(:user_collection_type) }

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:user) { create(:user, groups: 'admin') }
  let(:ability) { Ability.new(user) }
  let(:presenter) { Hyrax::CollectionPresenter.new(collection_doc, ability) }
  let(:current_ability) { Ability.new(user) }

  let(:blacklight_configuration_context) do
    Blacklight::Configuration::Context.new(controller)
  end

  let(:depositor) do
    stub_model(User,
               user_key: 'bob',
               twitter_handle: 'bot4lib')
  end

  let(:hyrax) { Hyrax::Engine.routes.url_helpers }

  describe 'catalog helper finds the text' do
    before do
      allow(view).to receive(:catalog).and_return('<mark>Test</mark>'.html_safe)
      allow(view).to receive(:current_ability).and_return(ability)
      allow(view).to receive(:document).and_return(collection_doc)
      allow(view).to receive(:blacklight_configuration_context).and_return(blacklight_configuration_context)
      allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
      allow(User).to receive(:find_by_user_key).and_return(depositor.user_key)
      allow(view).to receive(:can?).with(:edit, collection_doc).and_return(true)
      allow(view).to receive(:can?).with(:destroy, collection_doc).and_return(true)
      render 'catalog/index_header_list_collection', document: collection_doc
    end
    it "displays mark tag" do
      include MarkHelper
      expect(rendered).to include('<mark>Test</mark>')
    end
  end

  describe 'catalog helper doesnt finds the text' do
    before do
      allow(view).to receive(:catalog).and_return('Test'.html_safe)
      allow(view).to receive(:current_ability).and_return(ability)
      allow(view).to receive(:document).and_return(collection_doc)
      allow(view).to receive(:blacklight_configuration_context).and_return(blacklight_configuration_context)
      allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
      allow(User).to receive(:find_by_user_key).and_return(depositor.user_key)
      allow(view).to receive(:can?).with(:edit, collection_doc).and_return(true)
      allow(view).to receive(:can?).with(:destroy, collection_doc).and_return(true)
      render 'catalog/index_header_list_collection', document: collection_doc
    end
    it "doesnt displays mark tag" do
      include MarkHelper
      expect(rendered).not_to include('<mark>Test</mark>')
    end
  end
end
