# frozen_string_literal: true
require 'rails_helper'

describe ChangeManager::ComparisonConcern do
  let!(:editor_change) { FactoryBot.create(:change, change_type: 'added_as_editor') }
  let!(:proxy_change) { FactoryBot.create(:change, change_type: 'added_as_proxy') }
  describe '#proxy_change? should' do
    it 'return true when the change deals with a proxy' do
      expect(proxy_change.proxy_change?).to be true
    end

    it 'return false when the change does not deal with a proxy' do
      expect(editor_change.proxy_change?).to be false
    end
  end

  describe '#editor_change? should' do
    it 'return true when the change deals with an editor change' do
      expect(editor_change.editor_change?).to be true
    end

    it 'return false when the change does not deal with an editor change' do
      expect(proxy_change.editor_change?).to be false
    end
  end
end
