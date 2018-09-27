# frozen_string_literal: true
require 'rails_helper'
RSpec.describe 'errors/server_error.html.erb', type: :view do
  before do
    render
  end
  it 'tells the user what the error is' do
    expect(rendered).to have_content('Internal Server Error')
  end
  it 'assures the user someone has been alerted to the error' do
    expect(rendered).to have_content('An administrator has been notified of this error')
  end
end
