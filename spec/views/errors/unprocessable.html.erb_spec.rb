# frozen_string_literal: true
require 'rails_helper'
RSpec.describe 'errors/unprocessable.html.erb', type: :view do
  before do
    render
  end
  it 'tells the user what the error is' do
    expect(rendered).to have_content('We Couldn\'t Process Your Request')
  end
  it 'assures the use that someone has been alerted to the error' do
    expect(rendered).to have_content('An Administrator has been notified of this error.')
  end
end
