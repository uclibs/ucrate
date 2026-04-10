# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/_search_form.html.erb', type: :view do
  before do
    allow(view).to receive(:search_form_action).and_return("/catalog")
    allow(view).to receive(:search_state).and_return(search_state)
    allow(view).to receive(:current_search_parameters).and_return(nil)
    allow(view).to receive(:current_user).and_return(nil)

    render
  end
  let(:search_state) { double('SearchState', params_for_search: {}) }
  let(:page) { Capybara::Node::Simple.new(rendered) }

  it "has a hidden search_field input" do
    expect(page).to have_selector("[name='search_field'][value='all_fields']", visible: false)
  end

  it "uses a screen-reader-only label for the search field" do
    expect(rendered).to have_css('label.sr-only[for="search-field-header"]', text: /Search/)
  end

  it "does not use a visible Bootstrap control-label" do
    expect(rendered).not_to have_css('label.control-label')
  end
end
