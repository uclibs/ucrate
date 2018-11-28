# frozen_string_literal: true

require 'rails_helper'

describe 'hyrax/users/_vitals.html.erb', type: :view do
  let(:user) { stub_model(User, user_key: 'cam156') }
  let(:current_user) { stub_model(User, user_key: 'mjg') }

  before do
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(current_user)
    allow(view).to receive(:user).and_return(current_user)
    assign(:user, user)
    render
  end

  it 'displays user work and file analytics' do
    expect(rendered).to have_content 'File Views'
    expect(rendered).to have_content 'Work Views'
    expect(rendered).to have_content 'Downloads'
  end
end
