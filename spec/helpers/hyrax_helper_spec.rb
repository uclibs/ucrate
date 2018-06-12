# frozen_string_literal: true

require 'rails_helper'

def new_state
  Blacklight::SearchState.new({}, CatalogController.blacklight_config)
end

RSpec.describe HyraxHelper, type: :helper do
  describe '#available_translations' do
    subject(:translation) { helper.available_translations }

    it do
      is_expected.to eq('en' => 'English',
                        'es' => 'Español',
                        'zh' => '中文')
    end
  end
end
