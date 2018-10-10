# frozen_string_literal: true

require 'rails_helper'

describe 'hyrax/base/_form_visibility_component.html.erb', type: :view do
  let(:work) { stub_model(GenericWork, id: '456', title: ["A nice work"]) }
  let(:ability) { double }

  let(:form) do
    Hyrax::GenericWorkForm.new(work, ability, controller)
  end

  let(:f) do
    view.simple_form_for(form, url: '/update') do |work_form|
      return work_form
    end
  end

  before do
    allow(view).to receive(:f).and_return(f)
    allow(f).to receive(:object).and_return(form)
    assign(:form, form)
    render
  end

  it 'does not have a Lease option for visibility' do
    expect(rendered).not_to have_selector('div#collapseLease')
  end

  it 'does not show open access warning text' do
    expect(rendered).not_to have_content("making something visible to the world")
  end
end
