# frozen_string_literal: true
require 'rails_helper'

describe FilesReport do
  describe '#report_location' do
    it 'is vendor/files_report.csv' do
      expect(described_class.report_location).to eq("#{Rails.root}/vendor/files_report.csv")
    end
  end

  describe '#create_report' do
    let(:fake_files) { [
      FakeFile.new('id', 'title', 'label', 'file.pdf', 'foo@bar.org', 'foo@bar.org', ['foo@bar.org', 'foo@bar.org']),
      FakeFile.new('id', 'title', 'label', 'file.pdf', 'foo@bar.org', 'foo@bar.org', ['']),
      FakeFile.new('id', 'title', 'label', 'file.pdf', 'foo@bar.org', 'foo@bar.org', ['foo@bar.org']),
      FakeFile.new('id', 'title', 'label', 'file.pdf', 'foo@bar.org', 'foo@bar.org', ['foo@bar.org', 'foo@bar.org'])
    ] }

    before do
      FileSet.stub(:all).and_return(fake_files)

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
      ).to eq(fake_files.length + 1)
    end

    class FakeFile < Struct.new(:id, :title, :label, :filename, :creator, :depositor, :edit_users)
    end
  end
end