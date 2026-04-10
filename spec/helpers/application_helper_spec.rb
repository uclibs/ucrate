# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#thumbnail_alt_text_for' do
    it 'returns a non-nil alt text when title is missing' do
      record = instance_double(
        'Record',
        title_or_label: nil,
        title: nil,
        human_readable_type: 'Collection',
        to_s: ''
      )

      alt_text = helper.thumbnail_alt_text_for(record)

      expect(alt_text).to be_present
      expect(alt_text).to eq('Collection thumbnail')
    end

    it 'does not render a null label in alt text' do
      record = instance_double(
        'Record',
        title_or_label: 'null',
        title: ['null'],
        human_readable_type: 'Collection',
        to_s: 'null'
      )

      alt_text = helper.thumbnail_alt_text_for(record)

      expect(alt_text).to eq('Collection thumbnail')
      expect(alt_text.downcase).not_to include('null')
    end
  end
end
