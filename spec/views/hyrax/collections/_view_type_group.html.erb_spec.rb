# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/collections/_view_type_group.html.erb', type: :view do
  before do
    allow(view).to receive(:has_alternative_views?).and_return(true)
    allow(view).to receive(:document_index_views).and_return(
      list: double,
      gallery: double
    )
    allow(view).to receive(:document_index_view_type).and_return(:list)
    allow(view).to receive(:collection_path).with('col-1', view: :list).and_return('/collections/col-1?view=list')
    allow(view).to receive(:collection_path).with('col-1', view: :gallery).and_return('/collections/col-1?view=gallery')
    allow(view).to receive(:render_view_type_group_icon).and_return('<span class="ico"></span>'.html_safe)
    allow(view).to receive(:params).and_return(ActionController::Parameters.new(id: 'col-1'))
    render partial: 'hyrax/collections/view_type_group'
  end

  it 'does not duplicate visible labels in title attributes' do
    doc = Nokogiri::HTML::DocumentFragment.parse(rendered)
    doc.css('a.btn').each do |a|
      expect(a['title']).to be_nil
    end
  end
end
