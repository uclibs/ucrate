require 'rails_helper'

RSpec.describe 'hyrax/dashboard/profiles/edit.html.erb', type: :view do
  let(:user) { stub_model(User, user_key: 'mjg') }

  before do
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    assign(:user, user)
    assign(:trophies, [])
  end

  it "shows a first name and last name field" do
    render
    expect(rendered).to match(/First Name/)
    expect(rendered).to match(/Last Name/)
  end
end
