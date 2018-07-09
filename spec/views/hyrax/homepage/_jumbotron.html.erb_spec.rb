# frozen_string_literal: true
require 'rails_helper'

describe '/hyrax/homepage/_jumbotron.html.erb', type: :view do
  before do
    stub_template 'catalog/_search_form.html.erb' => 'search form'
    render
  end

  it "has jumbotron" do
    expect(rendered).to have_css('div.jumbotron')
  end

  it 'has jumbo scholar logo' do
    expect(rendered).to have_css("img[id*='jumbo-scholar-logo']")
  end

  it 'has navigation links' do
    expect(rendered).to have_link 'Contribute'
    expect(rendered).to have_link 'Browse'
  end

  it 'has cover photo attribution' do
    expect(rendered).to have_content('Photo by fusion-of-horizons')
    expect(rendered).to have_link('Photo', href: 'https://flic.kr/p/3kBWs4')
    expect(rendered).to have_link('CC-BY', href: 'https://creativecommons.org/licenses/by/2.0/')
  end
end
