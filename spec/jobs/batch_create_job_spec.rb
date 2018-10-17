# frozen_string_literal: true

require 'rails_helper'

describe BatchCreateJob do
  let(:user) { create(:user) }
  let(:operation) { create(:batch_create_operation, user: user) }
  let(:child_operation) { double }
  describe "#perform" do
    let(:file1) { File.open(fixture_path + '/world.png') }
    let(:file2) { File.open(fixture_path + '/image.jp2') }
    let(:upload1) { Hyrax::UploadedFile.create(user: user, file: file1) }
    let(:upload2) { Hyrax::UploadedFile.create(user: user, file: file2) }
    let(:title) { { upload1.id.to_s => 'File One', upload2.id.to_s => 'File Two' } }
    let(:metadata) { { subject: [], model: 'GenericWork' } }
    let(:uploaded_files) { [upload1.id.to_s, upload2.id.to_s] }

    subject(:test) do
      described_class.perform_later(user,
                                    title,
                                    uploaded_files,
                                    metadata,
                                    operation)
    end

    before do
      allow(Hyrax::Operation).to receive(:create!).with(user: user,
                                                        operation_type: "Create Work",
                                                        parent: operation).and_return(child_operation)
    end

    it "spawns CreateWorkJobs for each work" do
      expect(CreateWorkJob).to receive(:perform_later).with(user,
                                                            "GenericWork",
                                                            {
                                                              subject: [],
                                                              title: ['File One'],
                                                              uploaded_files: ['1']
                                                            },
                                                            child_operation).and_return(true)
      expect(CreateWorkJob).to receive(:perform_later).with(user,
                                                            "GenericWork",
                                                            {
                                                              subject: [],
                                                              title: ['File Two'],
                                                              uploaded_files: ['2']
                                                            },
                                                            child_operation).and_return(true)
      test
    end
  end
end
