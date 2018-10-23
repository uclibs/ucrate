# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/collections/_show_descriptions.html.erb', type: :view do
  context 'displaying a custom collection' do
    let(:collection_size) { 123_456_678 }
    let(:collection) do
      {
        id: '999',
        "has_model_ssim" => ["Collection"],
        "title_tesim" => ["Title 1"],
        'date_created_tesim' => '2000-01-01',
        "license_tesim" => ["http://creativecommons.org/publicdomain/zero/1.0/"]
      }
    end
    let(:ability) { double }
    let(:solr_document) { SolrDocument.new(collection) }
    let(:presenter) { Hyrax::CollectionPresenter.new(solr_document, ability) }

    before do
      allow(presenter).to receive(:total_items).and_return(2)
      allow(presenter).to receive(:size).and_return("118 MB")
      assign(:presenter, presenter)
    end

    it "displays the License label and License name hyperlinked" do
      render
      expect(rendered).to have_content 'License'
      expect(rendered).to have_link("CC0 1.0 Universal", href: "http://creativecommons.org/publicdomain/zero/1.0/")
    end
  end
end
