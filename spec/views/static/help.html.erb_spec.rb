# frozen_string_literal: true

require 'rails_helper'

describe '/static/help.html.erb', type: :view do
  before do
    render
  end

  it 'has external help links' do
    expect(rendered).to have_link('Accessibility at UC')
    expect(rendered).to have_link('Fair Use')
  end

  it 'has internal help links' do
    expect(rendered).to have_link(href: creators_rights_path)
    expect(rendered).to have_link(href: documenting_data_path)
    expect(rendered).to have_link(href: faq_path)
    expect(rendered).to have_link(href: format_advice_path)
    expect(rendered).to have_link(href: student_work_help_path)
    expect(rendered).to have_link(href: welcome_page_index_path)
  end
end
