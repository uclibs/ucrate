# frozen_string_literal: true
require 'rails_helper'

describe ChangeManager::ProcessChangeJob do
  describe '#perform' do
    let!(:change) { FactoryBot.build(:change) }
    it 'calls the process change method in ChangeManager::EmailManager' do
      expect(ChangeManager::EmailManager).to receive(:process_change).with(change.id)

      described_class.perform_now(change.id)
    end
  end
end
