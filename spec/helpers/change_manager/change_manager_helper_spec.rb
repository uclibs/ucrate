# frozen_string_literal: true
require 'rails_helper'

describe ChangeManager::ChangeManagerHelper do
  let!(:editors) { { "0" => { 'type' => 'person', 'name' => 'new_editor@example.com', 'access' => 'edit' } } }
  let!(:old_editor) { { 'id' => 'someid' } }
  let!(:new_editor) { { 'type' => 'person', 'name' => 'new_editor@example.com', 'access' => 'edit' } }
  let!(:removed_editor) { { 'id' => 'someid', '_destroy' => 'true', 'access' => 'destroy' } }
  let!(:curation_concern) { FactoryBot.create(:generic_work) }

  describe '#queue_notifications_for_editors should' do
    let(:change_email) { ActionMailer::Base.deliveries.last }
    let!(:user) { FactoryBot.create(:user, email: 'new_editor@example.com') }
    before do
      ActionMailer::Base.deliveries = []
    end

    after do
      ActionMailer::Base.deliveries = []
    end

    it 'queues the change in change manager and sends the appropriate email' do
      queue_notifications_for_editors(editors)
      expect(change_email.to).to match_array([editors['0']['name']])
      expect(change_email.from).to match_array(['scholar@uc.edu'])
    end
  end

  describe '#new_editor? should' do
    it 'return true when the editor is new' do
      expect(new_editor?(new_editor)).to be true
    end

    it 'return false when the editor is not new' do
      expect(new_editor?(old_editor)).to be false
    end
  end

  describe '#removed_editor? should' do
    it 'return true is the editor is removed' do
      expect(removed_editor?(removed_editor)).to be true
    end

    it 'return false if the editor is not removed' do
      expect(removed_editor?(new_editor)).to be false
    end
  end

  describe '#name_key? should' do
    it 'return true if the hash object has the name key' do
      expect(name_key?(new_editor)).to be true
    end

    it 'return false if the hash object does not have the name key' do
      expect(name_key?(old_editor)).to be false
    end
  end

  describe '#edit_access? should' do
    it 'return true if the editor has edit access' do
      expect(edit_access?(new_editor)).to be true
    end

    it 'return false if the editor does not have edit access' do
      expect(edit_access?(removed_editor)).to be false
    end
  end

  describe '#action' do
    it 'return corresponding change action value' do
      expect(action(new_editor)).to eq 'added_as_editor'
      expect(action(removed_editor)).to eq 'removed_as_editor'
    end
  end

  describe '#changed? should' do
    it 'return true when an editor is added' do
      expect(changed?(new_editor)).to be true
    end

    it 'return true when and editor is removed' do
      expect(changed?(removed_editor)).to be true
    end

    it 'return false with no changes' do
      expect(changed?(editors)).to be false
    end
  end
end
