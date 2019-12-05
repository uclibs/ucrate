# frozen_string_literal: true
RSpec.describe Hyrax::FixityCheckFailureService do
  let!(:log_date) { '2015-07-15 03:06:59' }
  let(:file) { Hydra::PCDM::File.new }
  let(:version_uri) { "#{file.uri}/fcr:versions/version1" }
  let!(:depositor) { create(:user) }
  let(:file_set) do
    create(:file_set, user: depositor, title: ["World Icon"]).tap { |fs| fs.original_file = file }
  end

  let(:checksum_audit_log) do
    ChecksumAuditLog.new(file_set_id: file_set.id,
                         file_id: file_set.original_file.id,
                         checked_uri: version_uri,
                         created_at: log_date,
                         updated_at: log_date,
                         passed: false)
  end

  describe "#call" do
    subject(:fixity_check) { described_class.new(file_set, checksum_audit_log: checksum_audit_log) }
    context "when no admin" do
      let(:depositor_inbox) { depositor.mailbox.inbox }
      it "sends failing mail" do
        fixity_check.call
        expect(depositor_inbox.count).to eq(1)
        depositor_inbox.each { |msg| expect(msg.last_message.subject).to eq('Failing Fixity Check') }
        depositor_inbox.each { |msg| expect(msg.last_message.body).to eq('The fixity check run at ' + checksum_audit_log.created_at.to_s + ' for ' + file_set.to_s + ' (' + file.uri + ') failed.') }
      end
    end

    context "when admin exists" do
      let!(:admin) { create(:admin, email: 'admin@example.com') }
      let(:admin_inbox) { admin.mailbox.inbox }
      let(:admin_file_set) do
        create(:file_set, user: admin, title: ["World Icon"]).tap { |fs| fs.original_file = file }
      end
      it "sends failing mail" do
        fixity_check.call
        expect(admin_inbox.count).to eq(1)
        admin_inbox.each { |msg| expect(msg.last_message.subject).to eq('Failing Fixity Check') }
        admin_inbox.each { |msg| expect(msg.last_message.body).to eq('The fixity check run at ' + checksum_audit_log.created_at.to_s + ' for ' + file_set.to_s + ' (' + file.uri + ') failed.') }
      end
    end
  end
end
