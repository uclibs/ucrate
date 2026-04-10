# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/users/_contributions.html.erb', type: :view do
  it 'renders trophy thumbnail alt text that is present and not null' do
    trophy = double(
      'SolrDocument',
      id: 'work-1',
      thumbnail_path: '/downloads/trophy-thumb.png',
      title_or_label: 'null',
      title: ['null'],
      human_readable_type: 'Generic Work',
      to_s: 'null'
    )
    presenter = double('Presenter', trophies: [trophy], current_user?: false, name: 'User')

    allow(view).to receive(:presenter).and_return(presenter)
    allow(view).to receive(:main_app).and_return(main_app)
    allow(view).to receive(:link_to) do |*_args, &block|
      block ? block.call : ''
    end

    render partial: 'hyrax/users/contributions', locals: { presenter: presenter }

    expect(rendered).to include('alt="Generic Work thumbnail"')
    expect(rendered.downcase).not_to include('thumbnail: null')
  end
end
