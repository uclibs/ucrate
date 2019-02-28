# frozen_string_literal: true
require 'rails_helper'

describe CollectionsReport do
  describe '#report_location' do
    it 'is vendor/collections_report.csv' do
      expect(described_class.report_location).to eq("#{Rails.root}/vendor/collections_report.csv")
    end
  end

  describe '#create_report' do
    let(:fake_collections) { [
      FakeCollection.new('pid', 'title', 'foo@bar.org', ['foo@bar.org'], ['pid', 'pid']),
      FakeCollection.new('pid', 'title', 'foo@bar.org', ['foo@bar.org'], ['pid']),
      FakeCollection.new('pid', 'title', 'foo@bar.org', ['foo@bar.org'], ['']),
      FakeCollection.new('pid', 'title', 'foo@bar.org', ['foo@bar.org'], ['pid', 'pid'])
    ] }

    before do
      Collection.stub(:all).and_return(fake_collections)

      File.delete(described_class.report_location) if File.exist?(described_class.report_location)
    end

    it 'creates a report in the report_location' do
      described_class.create_report
      expect(File).to exist(described_class.report_location)
    end

    it 'creates a report one line longer than the number of objects reported on' do
      described_class.create_report
      expect(
        File.open(described_class.report_location).readlines.size
      ).to eq(fake_collections.length + 1)
    end

    class FakeCollection < Struct.new(:id, :title, :depositor, :edit_users, :member_ids)
    end
  end
end