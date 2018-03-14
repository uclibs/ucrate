require 'rails_helper'

RSpec.describe 'devise/registrations/edit.html.erb', type: :view do
  let(:resource) { stub_model(User, user_key: 'mjg') }
  let(:resource_name) { :user }
  let(:devise_mapping) { Devise.mappings[:user] }

  before do
    allow(view).to receive(:resource).and_return(resource)
    allow(view).to receive(:resource_name).and_return(resource_name)
    allow(view).to receive(:devise_mapping).and_return(devise_mapping)
    render
  end

  it "does not allow the user to cancel their account" do
    expect(rendered).not_to have_content('Cancel my account')
  end
end
