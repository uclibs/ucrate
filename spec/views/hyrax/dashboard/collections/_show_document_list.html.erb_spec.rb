# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/dashboard/collections/_show_document_list.html.erb', type: :view do
  let(:documents) { [] }

  before do
    allow(view).to receive(:current_user).and_return(nil)
    stub_template 'hyrax/dashboard/collections/_show_document_list_row.html.erb' => ''
    render partial: 'hyrax/dashboard/collections/show_document_list', locals: { documents: documents }
  end

  it 'exposes an accessible name on the table without a caption' do
    expect(rendered).to have_css(
      'table.table[aria-label="List of items in this collection"]'
    )
    expect(rendered).not_to include('<caption')
  end

  it 'names the first column for assistive technology' do
    expect(rendered).to have_css('th.shared-deposit-indicator-col[scope="col"]')
    expect(rendered).to have_css('th .sr-only', text: 'Shared deposit indicator')
  end
end
