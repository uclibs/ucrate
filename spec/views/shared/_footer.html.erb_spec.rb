# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'shared/_footer.html.erb', type: :view do
  before do
    render
  end

  it 'displays a deployment timestamp' do
    expect(rendered).to have_content("Deployed on")
  end

  it 'displays a made possible by statement' do
    expect(rendered).to have_content("Made possible by")
  end

  it 'displays a terms and discrimination statement' do
    expect(rendered).to have_content("Terms of Use")
    expect(rendered).to have_content("Non-Discrimination")
  end

  it 'displays the copyright text' do
    expect(rendered).to have_content "© #{Time.zone.today.year} University of Cincinnati"
  end

  it 'displays the copyright information link' do
    expect(rendered).to have_content 'Copyright Information'
  end

  it 'displays the based on hyrax text' do
    expect(rendered).to have_content 'Based on Hyrax'
  end
end
