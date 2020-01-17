# frozen_string_literal: true

require 'rails_helper'

describe FixityCheckJob do
  let(:user) { create(:user) }

  let(:file_set) do
    create(:file_set, user: user).tap do |file|
      Hydra::Works::AddFileToFileSet.call(file, File.open(fixture_path + '/world.png'), :original_file, versioning: true)
    end
  end
  let(:file_id) { file_set.original_file.id }

  describe "called with perform_now" do
    let(:log_record) { described_class.perform_now(uri, file_set_id: file_set.id, file_id: file_id) }

    describe 'fixity check the content' do
      let(:uri) { file_set.original_file.uri }

      it 'passes' do
        expect(log_record).to be_passed
      end
      it "returns a ChecksumAuditLog" do
        expect(log_record).to be_kind_of ChecksumAuditLog
        expect(log_record.checked_uri).to eq uri
        expect(log_record.file_id).to eq file_id
        expect(log_record.file_set_id).to eq file_set.id
      end
    end

    describe 'fixity check a version of the content' do
      let(:uri) { Hyrax::VersioningService.latest_version_of(file_set.original_file).uri }

      it 'passes' do
        expect(log_record).to be_passed
      end
      it "returns a ChecksumAuditLog" do
        expect(log_record).to be_kind_of ChecksumAuditLog
      end
    end
    describe 'fixity check an invalid version of the content' do
      let(:uri) { Hyrax::VersioningService.latest_version_of(file_set.original_file).uri + 'bogus' }
      let(:log_record) { described_class.perform_now(uri, file_set_id: file_set.id, file_id: file_id) }

      it 'fails' do
        #        expect(job).to eq(false)
        expect(log_record).to be_failed
      end
      it "returns a ChecksumAuditLog" do
        #        expect(log_record).to be_kind_of ChecksumAuditLog
      end
    end
  end
end
