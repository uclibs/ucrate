# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/dashboard/profiles/edit.html.erb', type: :view do
  let(:user) { stub_model(User, user_key: 'mjg') }

  before do
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    assign(:user, user)
    assign(:trophies, [])
  end

  it "shows the user's name fields" do
    render
    expect(rendered).to match(/First Name/)
    expect(rendered).to match(/Last Name/)
  end

  it "shows the user's identity fields" do
    render
    expect(rendered).to match(/Job title/)
    expect(rendered).to match(/Department/)
    expect(rendered).to match(/UC affiliation/)
  end

  it "shows select fields as readonly" do
    render
    expect(rendered).to have_selector('input[id="user_ucdepartment"][readonly="readonly"]')
    expect(rendered).to have_selector('input[id="user_uc_affiliation"][readonly="readonly"]')
    expect(rendered).to have_selector('input[id="user_email"][readonly="readonly"]')
  end

  it "shows the user's contact fields" do
    render
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Alternate email/)
    expect(rendered).to match(/Campus phone number/)
    expect(rendered).to match(/Alternate phone number/)
  end

  it "shows the user's web fields" do
    render
    expect(rendered).to match(/Research Directory webpage/)
    expect(rendered).to match(/Personal webpage/)
    expect(rendered).to match(/Blog/)
  end

  it "does not show hyrax orcid field" do
    render
    expect(rendered).not_to match(/ORCID Profile/)
  end
end
