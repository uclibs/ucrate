# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/collections/_media_display.html.erb', type: :view do
  it 'renders thumbnail alt text that is present and does not include null' do
    presenter = instance_double(
      'Hyrax::CollectionPresenter',
      thumbnail_path: '/downloads/thumb.png',
      title_or_label: 'null',
      title: ['null'],
      human_readable_type: 'Collection',
      to_s: 'null'
    )

    render partial: 'hyrax/collections/media_display', locals: { presenter: presenter }

    expect(rendered).to include('alt="Collection thumbnail"')
    expect(rendered.downcase).not_to include('thumbnail: null')
  end
end
