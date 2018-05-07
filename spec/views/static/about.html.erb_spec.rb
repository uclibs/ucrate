# frozen_string_literal: true

require 'rails_helper'

describe '/static/about.html.erb', type: :view do
  before do
    render
  end

  it 'renders the about text' do
    expect(rendered).to render_template(partial: '/static/_about_text')
  end

  it 'has a link to Terms of Use' do
    expect(rendered).to have_link(href: hyrax.terms_path)
  end

  it 'has a link to the Collection Policy' do
    expect(rendered).to have_link(href: coll_policy_path)
  end
end
