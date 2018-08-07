# frozen_string_literal: true

require 'rails_helper'

describe ExpirationService do
  let(:embargo_date) { (Time.zone.today + 14.days) }
  let(:embargoed_work) { create(:private_generic_work, :with_public_embargo, title: ['Embargoed Work'], embargo_release_date: embargo_date) }
  let(:embargoed_file) { create(:file_set, :with_public_embargo, title: ['Embargoed File'], embargo_release_date: embargo_date) }

  after { ActiveFedora::Cleaner.clean! }

  context 'with an expired embargo' do
    it 'changes the visibility when it has expired' do
      expect(embargoed_work.visibility).to eq('restricted')
      expect(VisibilityCopyJob).to receive(:perform_later).with(embargoed_work)
      described_class.call(embargo_date)
      embargoed_work.reload
      expect(embargoed_work.visibility).to eq('open')
      expect(embargoed_work.embargo.embargo_history.first).to start_with('An active embargo was deactivated')
    end
  end

  context 'with an expired embargoed file' do
    it 'changes the visibility when it has expired' do
      expect(embargoed_file.visibility).to eq('restricted')
      expect(VisibilityCopyJob).to receive(:perform_later).with(embargoed_work)
      described_class.call(embargo_date)
      embargoed_file.reload
      expect(embargoed_file.visibility).to eq('open')
      expect(embargoed_file.embargo.embargo_history.first).to start_with('An active embargo was deactivated')
    end
  end

  context 'with an expired embargo in the past', :clean_repo do
    let(:embargo_date_in_past) { (Time.zone.today + 1.day) }
    let(:embargoed_work) { create(:private_generic_work, :with_public_embargo, title: ['Embargoed Work'], embargo_release_date: embargo_date_in_past) }

    it 'changes the visibility after it has expired' do
      expect(embargoed_work.visibility).to eq('restricted')
      expect(VisibilityCopyJob).to receive(:perform_later).with(embargoed_work)
      described_class.call(embargo_date)
      embargoed_work.reload
      expect(embargoed_work.visibility).to eq('open')
      expect(embargoed_work.embargo.embargo_history.first).to start_with('An active embargo was deactivated')
    end
  end

  context 'with an unexpired embargo' do
    it 'does not change the visibility when it has not expired' do
      expect(embargoed_work.visibility).to eq('restricted')
      expect(VisibilityCopyJob).not_to receive(:perform_later).with(embargoed_work)
      described_class.call
      embargoed_work.reload
      expect(embargoed_work.visibility).to eq('restricted')
      expect(embargoed_work.embargo.embargo_history).to be_empty
    end
  end

  context 'with a previously expired embargo' do
    before do
      embargoed_work.deactivate_embargo!
      embargoed_work.embargo.save
    end
    it 'does not change the visibility' do
      expect(VisibilityCopyJob).not_to receive(:perform_later).with(embargoed_work)
      described_class.call(embargo_date)
    end
  end
end
