# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/my/_search_form.html.erb', type: :view do
  let(:search_state) { double('SearchState', params_for_search: {}) }
  before do
    view.extend Hyrax::BatchEditsHelper
    allow(view).to receive(:search_state).and_return(search_state)
    allow(view).to receive(:on_the_dashboard?).and_return(true)
    allow(view).to receive(:search_action_url).and_return('')
    render
  end

  it "does not have a search label" do
    expect(rendered).not_to have_css('label.control-label')
  end
end
