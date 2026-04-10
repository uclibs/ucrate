# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/base/_parent_relationship_table.html.erb', type: :view do
  let(:child_id) { 'child-work-1' }

  before do
    allow(view).to receive(:url_for_document).and_return('/concern/parent/1')
  end

  context 'when the work has no parent works' do
    before do
      allow(ParentQueryService).to receive(:query_parents_for_id).with(child_id).and_return([])
    end

    it 'does not render an empty heading' do
      render partial: 'hyrax/base/parent_relationship_table', locals: { child_id: child_id }

      expect(rendered).not_to have_css('h2')
    end
  end

  context 'when the work has parent works' do
    before do
      allow(ParentQueryService).to receive(:query_parents_for_id).with(child_id).and_return(
        [{ 'id' => 'parent-1', 'title_tesim' => ['Parent work title'] }]
      )
      allow(SolrDocument).to receive(:find).with('parent-1').and_return(instance_double(SolrDocument))
    end

    it 'renders the relationships heading' do
      render partial: 'hyrax/base/parent_relationship_table', locals: { child_id: child_id }

      expect(rendered).to have_css('h2', text: I18n.t('hyrax.base.relationships.label'))
      expect(rendered).to have_link('Parent work title', href: '/concern/parent/1')
    end
  end
end
