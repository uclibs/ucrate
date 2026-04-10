# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/dashboard/collections/_show_document_list_row.html.erb', type: :view do
  let(:collection) { instance_double(Collection, id: 'col-1') }
  let(:document) do
    SolrDocument.new(
      id: 'k0698748f',
      'title_tesim' => ['Image Title'],
      'depositor_ssim' => ['person@example.com'],
      'has_model_ssim' => [Image.to_s]
    )
  end

  before do
    assign(:collection, collection)
    allow(view).to receive(:current_user).and_return(nil)
    allow(view).to receive(:can?).with(:edit, collection).and_return(false)
    allow(view).to receive(:render_thumbnail_tag).and_return('<img src="/thumb.png" alt="thumb" />')
    allow(view).to receive(:render_visibility_link).and_return('')
    allow(view).to receive(:render_collection_links).and_return('')
    render partial: 'hyrax/dashboard/collections/show_document_list_row', locals: { document: document }
  end

  it 'links the title to the work but not the thumbnail (avoids redundant same-URL links)' do
    doc = Nokogiri::HTML::DocumentFragment.parse(rendered)
    work_hrefs = doc.css(%(a[href="/concern/images/k0698748f"]))
    expect(work_hrefs.size).to eq(1)
    expect(work_hrefs.first['id']).to eq('src_copy_linkk0698748f')
    expect(work_hrefs.first.text).to include('Image Title')
    expect(doc.at_css('.media-left a')).to be_nil
  end
end
