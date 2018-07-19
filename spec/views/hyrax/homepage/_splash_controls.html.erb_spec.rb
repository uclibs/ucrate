# frozen_string_literal: true
require 'rails_helper'

describe '/hyrax/homepage/_splash_controls.html.erb', type: :view do
  before do
    stub_template 'catalog/_search_form.html.erb' => 'search form'
    render
  end

  it 'has navigation links' do
    expect(rendered).to have_link 'People'
    expect(rendered).to have_link 'About'
    expect(rendered).to have_link 'Contact'
    expect(rendered).to have_link 'Help'
  end
end
