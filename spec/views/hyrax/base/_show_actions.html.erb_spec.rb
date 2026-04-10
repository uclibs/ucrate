# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/base/_show_actions.html.erb', type: :view do
  context 'when user may add work to a collection' do
    let(:presenter) do
      double(
        'WorkShowPresenter',
        id: '9593tv123',
        editor?: false,
        member_presenters: [],
        valid_child_concerns: [],
        work_featurable?: false,
        show_deposit_for?: true
      )
    end

    before do
      assign(:user_collections, [])
      assign(:presenter, presenter)
      allow(Hyrax.config).to receive(:analytics?).and_return(false)
      stub_template 'hyrax/dashboard/collections/form_for_select_collection.html.erb' => ''
      render partial: 'hyrax/base/show_actions', locals: { presenter: presenter }
    end

    it 'associates a screen-reader label and aria-label with the batch checkbox' do
      expect(rendered).to have_css('label.sr-only[for="batch_document_9593tv123"]',
                                   text: 'Include this work when adding to a collection')
      expect(rendered).to have_css(
        'input.batch_document_selector#batch_document_9593tv123[aria-label="Include this work when adding to a collection"]',
        visible: :hidden
      )
    end

    it 'exposes an accessible name on the add to collection control' do
      expect(rendered).to have_css(
        'button.submits-batches-add[type="button"][aria-label="Add to collection"]',
        text: 'Add to collection'
      )
    end
  end
end
