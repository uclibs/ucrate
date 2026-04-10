# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/homepage/_featured_collections.html.erb', type: :view do
  it 'renders a featured collection thumbnail with non-null alt text' do
    featured_collection = instance_double('FeaturedCollection', collection_id: 'col-123')
    collection = double(
      'Collection',
      to_solr: { 'thumbnail_path_ss' => '/downloads/featured-thumb.png' },
      title_or_label: 'null',
      title: ['null'],
      human_readable_type: 'Collection',
      to_s: 'null'
    )

    allow(FeaturedCollection).to receive(:count).and_return(1)
    allow(FeaturedCollection).to receive(:first).and_return(featured_collection)
    allow(Collection).to receive(:find).with('col-123').and_return(collection)
    allow(view).to receive(:collection_path).with('col-123').and_return('/collections/col-123')

    render partial: 'hyrax/homepage/featured_collections'

    expect(rendered).to include('alt="Collection thumbnail"')
    expect(rendered.downcase).not_to include('thumbnail: null')
  end
end
