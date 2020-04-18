# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe 'catalog/_index_header_list_default', type: :view do
  let(:attributes) do
    { 'id' => '123',
      'title_tesim' => 'Test Work',
      'creator_tesim' => ['Justin', 'Joe'],
      'depositor_tesim' => ['jcoyne@justincoyne.com'],
      'proxy_depositor_ssim' => ['atz@stanford.edu'],
      'description_tesim' => ['This links to http://example.com/ What about that?'],
      'date_uploaded_dtsi' => '2013-03-14T00:00:00Z',
      'license_tesim' => ["http://creativecommons.org/publicdomain/zero/1.0/",
                          "http://creativecommons.org/publicdomain/mark/1.0/",
                          "http://www.europeana.eu/portal/rights/rr-r.html"],
      'rights_statement_tesim' => ['http://rightsstatements.org/vocab/InC/1.0/'],
      'identifier_tesim' => ['65434567654345654'],
      'keyword_tesim' => ['taco', 'mustache'],
      'subject_tesim' => ['Awesome'],
      'contributor_tesim' => ['Bird, Big'],
      'publisher_tesim' => ['Penguin Random House'],
      'based_near_label_tesim' => ['Pennsylvania'],
      'language_tesim' => ['English'],
      'resource_type_tesim' => ['Capstone Project'],
      'has_model_ssim' => ['GenericWork'] }
  end

  let(:document) { SolrDocument.new(attributes) }
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:user) { create(:user, groups: 'admin') }
  let(:ability) { Ability.new(user) }
  let(:presenter) { Hyrax::CollectionPresenter.new(document, ability) }
  let(:current_ability) { Ability.new(user) }

  let(:blacklight_configuration_context) do
    Blacklight::Configuration::Context.new(controller)
  end

  let(:depositor) do
    stub_model(User,
               user_key: 'bob',
               twitter_handle: 'bot4lib')
  end

  describe 'catalog helper finds the text' do
    before do
      allow(view).to receive(:catalog).and_return('<mark>Test</mark>'.html_safe)
      allow(view).to receive(:current_ability).and_return(ability)
      allow(view).to receive(:document).and_return(document)
      allow(view).to receive(:blacklight_configuration_context).and_return(blacklight_configuration_context)
      allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
      allow(User).to receive(:find_by_user_key).and_return(depositor.user_key)
      allow(presenter).to receive(:field_value) { |field| "Test #{field}" }
      allow(view).to receive(:can?).with(:edit, document).and_return(true)
      allow(view).to receive(:can?).with(:destroy, document).and_return(true)
      render 'catalog/index_header_list_default', document: document
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
      allow(view).to receive(:document).and_return(document)
      allow(view).to receive(:blacklight_configuration_context).and_return(blacklight_configuration_context)
      allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
      allow(User).to receive(:find_by_user_key).and_return(depositor.user_key)
      allow(presenter).to receive(:field_value) { |field| "Test #{field}" }
      allow(view).to receive(:can?).with(:edit, document).and_return(true)
      allow(view).to receive(:can?).with(:destroy, document).and_return(true)
      render 'catalog/index_header_list_default', document: document
    end
    it "doesnt displays mark tag" do
      include MarkHelper
      expect(rendered).not_to include('<mark>Test</mark>')
    end
  end
end
