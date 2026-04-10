# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/file_sets/media_display/_pdf.html.erb', type: :view do
  let(:file_set) do
    instance_double(
      Hyrax::FileSetPresenter,
      id: 'fs-pdf',
      human_readable_type: 'File Set',
      title: ['Thesis.pdf'],
      title_or_label: 'Thesis.pdf'
    )
  end

  before do
    allow(view).to receive(:thumbnail_url).with(file_set).and_return('/downloads/thumb.png')
    allow(Hyrax.config).to receive(:display_media_download_link?).and_return(false)
  end

  it 'renders the PDF preview thumbnail with descriptive alt text' do
    render partial: 'hyrax/file_sets/media_display/pdf', locals: { file_set: file_set }

    expect(rendered).to include('alt="File Set thumbnail: Thesis.pdf"')
    expect(rendered).not_to include('role="presentation"')
  end
end
