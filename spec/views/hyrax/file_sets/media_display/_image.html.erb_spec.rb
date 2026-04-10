# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/file_sets/media_display/_image.html.erb', type: :view do
  let(:file_set) do
    instance_double(
      Hyrax::FileSetPresenter,
      id: 'fs1',
      human_readable_type: 'File Set',
      title: ['Scan page 1'],
      title_or_label: 'Scan page 1'
    )
  end

  before do
    allow(view).to receive(:thumbnail_url).with(file_set).and_return('/downloads/thumb.png')
  end

  context 'when downloadable content is disabled' do
    before do
      allow(Hyrax.config).to receive(:display_media_download_link?).and_return(false)
    end

    it 'renders the thumbnail with descriptive alt text' do
      render partial: 'hyrax/file_sets/media_display/image', locals: { file_set: file_set }

      expect(rendered).to include('alt="File Set thumbnail: Scan page 1"')
      expect(rendered).not_to include('role="presentation"')
    end
  end

  context 'when downloadable content is enabled and user may download' do
    before do
      allow(Hyrax.config).to receive(:display_media_download_link?).and_return(true)
      allow(view).to receive(:can?).with(:download, 'fs1').and_return(true)
      allow(view).to receive(:hyrax).and_return(double(download_path: '/downloads/fs1'))
    end

    it 'renders the thumbnail with descriptive alt text' do
      render partial: 'hyrax/file_sets/media_display/image', locals: { file_set: file_set }

      expect(rendered).to include('alt="File Set thumbnail: Scan page 1"')
      expect(rendered).not_to include('role="presentation"')
    end
  end
end
