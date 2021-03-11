# frozen_string_literal: true
require 'rails_helper'

RSpec.describe WorkAndFileIndex, type: :model do
  it 'has attributes' do
    expect(subject).to respond_to(:object_id)
    expect(subject).to respond_to(:object_type)
    expect(subject).to respond_to(:user_email)
    expect(subject).to respond_to(:stats_last_gathered)
  end

  describe '#update_stats_last_gathered' do
    it 'updates #stats_last_gathered to today' do
      expect(subject.stats_last_gathered).to be_nil
      subject.update_stats_last_gathered
      expect(subject.stats_last_gathered.today?).to be(true)
    end
  end

  describe '#reset' do
    let!(:work1) { create(:work) }
    let!(:work2) { create(:work) }
    let!(:work3) { create(:generic_work_with_one_file) }
    let!(:work4) { create(:generic_work_with_one_file) }
    let(:file1) { work3.file_sets.first }
    let(:file2) { work4.file_sets.first }

    let!(:old_records) do
      (1..3).map { described_class.create }
    end

    it 'removes all of the old records' do
      described_class.reset
      old_records.each do |record|
        expect { record.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    it 'adds a new record for each object, with the correct attributes' do
      # this is longer than it needs to be to speed up the test

      described_class.reset
      # works
      expect(described_class.find_by(object_id: work1.id).class).to be(described_class)
      expect(described_class.find_by(object_id: work2.id).class).to be(described_class)
      expect(described_class.find_by(object_id: work3.id).class).to be(described_class)
      expect(described_class.find_by(object_id: work4.id).class).to be(described_class)

      # files
      expect(described_class.find_by(object_id: file1.id).class).to be(described_class)
      expect(described_class.find_by(object_id: file2.id).class).to be(described_class)

      # work attributes
      work = described_class.find_by(object_id: work1.id)
      expect(work.object_id).to eq(work1.id)
      expect(work.user_email).to eq(work1.depositor)
      expect(work.stats_last_gathered).to eq(nil)
      expect(work.object_type).to eq("work")

      # file attributes
      file = described_class.find_by(object_id: file1.id)
      expect(file.object_id).to eq(file1.id)
      expect(file.user_email).to eq(file1.depositor)
      expect(file.stats_last_gathered).to eq(nil)
      expect(file.object_type).to eq("file")
    end
  end

  describe '#update_works_and_files' do
    let!(:work1) { create(:generic_work_with_one_file) }
    let(:file1) { work1.file_sets.first }

    before { described_class.reset }

    context 'when objects are deleted' do
      it 'removes records for works that have been deleted' do
        work1.destroy

        described_class.update_works_and_files
        expect(described_class.find_by(object_id: work1.id)).to be_nil
      end

      it 'removes records for files that have been deleted' do
        file1.destroy

        described_class.update_works_and_files
        expect(described_class.find_by(object_id: file1.id)).to be_nil
      end
    end

    context 'when objects are added' do
      let!(:work2) { create(:generic_work_with_one_file) }
      let(:file2) { work2.file_sets.first }

      it 'adds records for works that have been added' do
        described_class.update_works_and_files
        expect(described_class.find_by(object_id: work2.id).class).to be(described_class)
      end

      it 'adds records for files that have been added' do
        described_class.update_works_and_files
        expect(described_class.find_by(object_id: file2.id).class).to be(described_class)
      end
    end
  end
end
