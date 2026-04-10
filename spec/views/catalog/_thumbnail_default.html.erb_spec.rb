# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/_thumbnail_default.html.erb', type: :view do
  it 'renders a thumbnail image with non-null alt text' do
    document = double('SolrDocument')

    allow(view).to receive(:has_thumbnail?).with(document).and_return(true)
    allow(view).to receive(:document_counter_with_offset).with(1).and_return(1)
    allow(view).to receive(:render_thumbnail_tag)
      .with(document, {}, hash_including(tabindex: -1, counter: 1))
      .and_return('<img src="/downloads/thumb.png" alt="Collection thumbnail">'.html_safe)

    render partial: 'catalog/thumbnail_default', locals: { document: document, document_counter: 1 }

    expect(rendered).to include('alt="Collection thumbnail"')
    expect(rendered.downcase).not_to include('thumbnail: null')
  end
end
