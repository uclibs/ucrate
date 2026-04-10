# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/collections/_search_form.html.erb', type: :view do
  let(:document) do
    SolrDocument.new(id: 'col-1',
                     'title_tesim' => ['Test Collection'])
  end
  let(:ability) { instance_double(Ability) }
  let(:presenter) { Hyrax::CollectionPresenter.new(document, ability) }
  let(:search_state) { instance_double(Blacklight::SearchState, params_for_search: {}) }

  before do
    allow(document).to receive(:hydra_model).and_return(::Collection)
    allow(ability).to receive(:user_groups).and_return([])
    allow(ability).to receive(:current_user).and_return(nil)
    allow(view).to receive(:search_state).and_return(search_state)
    render partial: 'hyrax/collections/search_form', locals: { presenter: presenter, url: '/collections/col-1' }
  end

  it 'associates the collection search field with a screen-reader-only label' do
    expect(rendered).to have_css('label.sr-only[for="collection_search"]', text: /Test Collection/)
    expect(rendered).to have_css('input#collection_search.collection-query[type="search"]')
  end
end
