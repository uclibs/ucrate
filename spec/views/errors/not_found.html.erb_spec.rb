# frozen_string_literal: true
require 'rails_helper'
RSpec.describe 'errors/not_found.html.erb', type: :view do
  before do
    render
  end
  it 'tells the user what the error is' do
    expect(rendered).to have_content('Whoops! We couldn\'t find the page you were looking for.')
  end
end
