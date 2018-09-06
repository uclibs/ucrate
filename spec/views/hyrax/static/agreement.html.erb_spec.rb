# frozen_string_literal: true

require 'rails_helper'

describe '/hyrax/static/agreement.html.erb', type: :view do
  before do
    render
  end

  it 'has the correct text and jumbotron' do
    puts rendered
    expect(rendered).to have_selector('h2', text: "Non-Exclusive Distribution License")
  end
end
