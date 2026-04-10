# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/base/_representative_media.html.erb', type: :view do
  context 'when the work has no representative file' do
    let(:presenter) do
      double(
        'WorkShowPresenter',
        representative_id: nil,
        representative_presenter: nil,
        human_readable_type: 'Generic Work',
        title: ['Untitled deposit'],
        title_or_label: 'Untitled deposit'
      )
    end

    it 'renders default artwork with work-based alt text' do
      render partial: 'hyrax/base/representative_media', locals: { presenter: presenter }

      expect(rendered).to match(%r{src="[^"]*default[^"]*\.png})
      expect(rendered).to include('alt="Generic Work thumbnail: Untitled deposit"')
      expect(rendered).to include('canonical-image')
    end
  end
end
